require "csv"

datasets = CSV.table "datasets.csv"

def reconstructed_from_raw filename
  reconstructed = filename.sub("{", "")
  reconstructed.sub!("}", "")
  reconstructed.sub!("..", "_S00")
  reconstructed
end

def csv_filename raw
  reconstructed = reconstructed_from_raw raw
  folder = "data"
  date = reconstructed.split("/")[8]
  basename = "#{date}.#{File.basename(reconstructed, ".hdf5")}.csv"
  File.join(folder, basename)
end

namespace :reconstruction do

  datasets.each do |row|
    raw = row[:filenames]
    expanded = %x{bash -c "realpath #{raw}"}
    expanded.gsub!(/\n/, " ")
    reconstructed = reconstructed_from_raw raw

    desc "dpc_reconstruction of #{reconstructed}"
    file reconstructed do |f|
      Dir.chdir "../dpc_reconstruction" do
        sh "dpc_radiography #{expanded}"
      end
    end
  end

  rec = datasets[:filenames].map {|raw| reconstructed_from_raw(raw)}
  file "reconstructed.csv" => rec do |f|
    datasets[:reconstructed] = rec
    File.open(f.name, "w") do |file|
      file.write(datasets.to_csv)
    end
  end

end

namespace :lungselection do

  datasets.each do |row|
    raw = row[:filenames]
    csv_output = csv_filename raw
    desc "shape selection of #{csv_output}"
    file csv_output => ["lung_selection.py", reconstructed_from_raw(raw)] do |f|
      sh "python #{f.prerequisites[0]} #{f.prerequisites[1]} #{f.name}"
    end
  end

end
