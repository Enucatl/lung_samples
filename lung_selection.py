import click
import h5py
import numpy as np
from scipy import stats
import matplotlib.pyplot as plt
from matplotlib.widgets import LassoSelector
from matplotlib import path
import csv


@click.command()
@click.argument("filename", type=click.Path(exists=True))
@click.argument("outputname", type=click.Path(exists=False))
def main(filename, outputname):
    dataset = h5py.File(filename)["postprocessing/dpc_reconstruction"]
    visibility = h5py.File(filename)["postprocessing/visibility"]
    absorption = dataset[..., 0]
    differential_phase = dataset[..., 1]
    dark_field = dataset[..., 2]
    fig, ax = plt.subplots()
    # limits = [0.7, 1]
    limits = stats.mstats.mquantiles(absorption, prob=[0.1, 0.9])
    print(limits)
    image = ax.imshow(absorption, interpolation="none", aspect='auto')
    image.set_clim(*limits)
    xv, yv = np.meshgrid(
        np.arange(absorption.shape[0]),
        np.arange(absorption.shape[1])
    )
    pix = np.transpose(np.vstack(
        (yv.flatten(), xv.flatten())
    ))

    def onselect(verts):
        global ind
        p = path.Path(verts)
        ind = p.contains_points(pix, radius=1)
        ind = np.reshape(ind, absorption.shape, order="F")

    plt.ion()
    lasso = LassoSelector(ax, onselect, lineprops={"color": "red"})
    plt.show()
    input('Press any key to accept selected points')
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
