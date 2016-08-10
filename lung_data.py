import click
import h5py
import numpy as np
import csv


@click.command()
@click.argument("filename", type=click.Path(exists=True))
@click.argument("indname", type=click.Path(exists=True))
@click.argument("outputname", type=click.Path(exists=True))
def main(filename, indname, outputname):
    dataset = h5py.File(filename)["postprocessing/dpc_reconstruction"]
    visibility = h5py.File(filename)["postprocessing/visibility"]
    ind = np.load(indname)
    print(ind)
    absorption = dataset[..., 0]
    differential_phase = dataset[..., 1]
    dark_field = dataset[..., 2]
    with open(outputname, "w") as outputfile:
        writer = csv.writer(outputfile)
        writer.writerow(["A", "P", "B", "R", "v"])
        for a, p, b, v in zip(
                absorption[ind],
                differential_phase[ind],
                dark_field[ind],
                visibility[ind],
                ):
            writer.writerow([a, p, b, np.log(b) / np.log(a), v])

if __name__ == "__main__":
    main()
