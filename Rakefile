require "csv"

def reconstructed_from_raw filename
  reconstructed = filename.sub("{", "")
  reconstructed.sub!("}", "")
  reconstructed.sub!("..", "_S00")
  reconstructed
end

def animal name
  if name[0] == "R"
    "rat"
  else
    "human"
  end
end

def csv_from_raw raw
  reconstructed = reconstructed_from_raw raw
  folder = "data"
  date = reconstructed.split("/")[8]
  basename = "#{date}.#{File.basename(reconstructed, ".hdf5")}.csv"
  File.join(folder, basename)
end

datasets = CSV.table "datasets.csv"
rec = datasets[:filenames].map {|raw| reconstructed_from_raw(raw)}
csvs = datasets[:filenames].map {|raw| csv_from_raw(raw)}
animals = datasets[:name].map {|name| animal(name)}
datasets[:reconstructed] = rec
datasets[:csv] = csvs
datasets[:type] = animals

namespace :reconstruction do

  datasets.each do |row|
    raw = row[:filenames]
    expanded = %x{bash -c "realpath #{raw}"}
    expanded.gsub!(/\n/, " ")
    reconstructed = reconstructed_from_raw raw

    desc "dpc_reconstruction of #{reconstructed}"
    file reconstructed => expanded.split(" ") do |f|
      Dir.chdir "../dpc_reconstruction" do
        sh "dpc_radiography #{expanded}"
      end
    end
  end

  file "reconstructed.csv" => rec do |f|
    File.open(f.name, "w") do |file|
      file.write(datasets.to_csv)
    end
  end

end

namespace :lungselection do

  datasets.each do |row|
    raw = row[:filenames]
    reconstructed = reconstructed_from_raw raw
    csv_output = csv_from_raw raw
    npy_output = File.join(
      File.dirname(csv_output),
      File.basename(csv_output, ".csv") + ".npy"
    )

    desc "export selection to #{csv_output}"
    file csv_output => ["lung_data.py", reconstructed, npy_output] do |f|
      sh "python #{f.prerequisites[0]} #{f.prerequisites[1]} #{f.prerequisites[2]} #{f.name}"
    end

    desc "shape selection to #{npy_output}"
    file npy_output => ["lung_selection.py", reconstructed_from_raw(raw)] do |f|
      sh "python #{f.prerequisites[0]} #{f.prerequisites[1]} #{f.name}"
    end
  end

end

namespace :analysis do

  desc "merge the csv datasets into one table"
  file "data/pixels.rds" => ["reconstructed.csv"] + datasets[:csv] do |f|
    sh "./merge_datasets.R -f #{f.source} -o #{f.name}"
  end

  desc "single dataset plots"
  file "plots/ratio.png" => ["single_dataset_histogram.R", "data/pixels.rds"] do |f|
    sh "./#{f.prerequisites[0]} -f #{f.prerequisites[1]} -o #{f.name}"
  end

end

task :default => ["plots/ratio.png"]
