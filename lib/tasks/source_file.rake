namespace :source_file do
  task create_imports: :environment do
    SourceFile.missing_import.find_each.with_index do |source_file, index|
      source_file.create_import!

      if (index+1) % 200 == 0
        puts "Record count: #{index+1}"
        sleep 10
      end
    end
  end
end
