module LogFileGenerator
    def self.create_file_with_dirs(file_path)
        dir_path = File.dirname(file_path)
        FileUtils.mkdir_p(dir_path) unless File.directory?(dir_path)
    end
end