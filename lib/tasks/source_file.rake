namespace :source_file do
  task create_imports: :environment do
    SourceFile.missing_import.find_each do |source_file|
      count = 0
      import = source_file.create_import!

      if import
        count += 1

        if count % 200 == 0
          puts "Record count: #{index + 1}"
          sleep 10
        end
      end
    end
  end
end
