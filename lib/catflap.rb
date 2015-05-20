require "catflap/version"
require 'shellwords'
require 'pathname'
require 'find'
require 'time'
require 'zlib'

module Catflap
  def sanity_check_sync sync
    return true if !FileTest.exists?(sync["name"])

    all = if FileTest.directory?(sync["name"])
      [sync["name"]] + Find.find(sync["name"]).to_a
    else
      [sync["name"]]
    end

    all.each do |a| sanity_check_file a end
  end

  def sanity_check_file file
    if (FileTest.directory?(file) || file =~ /.exe$/i) && !FileTest.executable?(file)
      $stderr.puts ("Warning: #{file} is not marked executable (chmod +x #{file}).").white.on_red
    end
  end

  def compare_sync a, b
    a["name"] == b["name"] &&
      a["size"] == b["size"] &&
      a["count"] == b["count"] &&
      DateTime.parse(a["mtime"]) == DateTime.parse(b["mtime"])
  end

  def update_sync_item baseDir, obj, flags = nil, generate_hashes = false
    current = $manifest["sync"].find {|s| s["name"] == obj}

    sync = if current
      current.dup
    else
      {
        "name"  => obj,
        "revision" => 1
      }
    end

    if File.directory?(baseDir + obj)
      all = Find.find(baseDir + obj).reject {|x| x =~ /\.rsyncsums$/ }

      files = all.reject {|x| File.directory?(x) }

      sync["size"] = files.map{|x| File.size(x) }.inject(0, :+)
      sync["count"] = files.size

      # We need to update the base mtime for dirs. This might be a bad place to do it, though.
      latestMtime = all.map {|f| File.mtime(f) }.max
      File.utime(File.atime(baseDir + obj), latestMtime, baseDir + obj)
      sync["mtime"] = latestMtime.iso8601(0)

      #files.each {|x| sanity_check_file x }

    else

      sync["size"] = File.size(baseDir + obj)
      sync["mtime"] = File.mtime(baseDir + obj).iso8601(0)

      #sanity_check_file baseDir + obj
    end

    if flags != nil
      sync.delete("ignoreExisting")
      sync["ignoreExisting"] = true if flags.index("i")
      sync.delete("mode")
      sync["mode"] = "replace" if flags.index("r")
      sync.delete("purge")
      sync["purge"] = true if flags.index("P")
      sync.delete("fuzzy")
      sync["fuzzy"] = true if flags.index("f")
    end

    sync.delete("csize")

    if current && sync != current
      sync["revision"] ||= 0
      sync["revision"] += 1
    end

    if generate_hashes
      sync["hashes"] ||= {}
      if sync["hashes"].size == 0 || current && sync != current

        files_to_hash = ([sync["name"]] + Dir[sync["name"] + "/**"]).
          select {|x| FileTest.file?(x)}.
          map {|x| Pathname.new(x).cleanpath.to_s }

        hashes =  `md5sum #{files_to_hash.map {|fn| Shellwords.shellescape(fn) }.join(' ')}`
        $? == 0 or fail "md5sum failed, ERROR"

        hashes = Hash[hashes.split("\n").map {|ln| ln.split(/\s+/).reverse.map(&:downcase) }]

        sync["hashes"] = hashes


        # puts "(Hashing #{sync["name"]})"
        # hash = `md5sum #{sync["name"]}`.split(/\s+/).map(&:strip)[0]
        # sync["hashes"][sync["name"]] = hash
        # fail "need to hash #{sync["name"]}: #{hash}"
      end
    end

    sync
  end
end
