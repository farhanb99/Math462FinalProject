import argparse
import numpy as np
import h5py
from matplotlib.animation import FuncAnimation
import matplotlib.pyplot as plt
import os



if __name__ == '__main__':

    # Create an argument parser object and add arguments for input file, output file, speed, and quality
    parser = argparse.ArgumentParser(description='Program that generates movie for stadium wave')
    parser.add_argument('input_file', type=str, help='input file name')
    parser.add_argument('--out', type=str, help='output file name')
    parser.add_argument('--speed', type=int, default=10, help='speed')
    parser.add_argument('--qual', choices=['low', 'med', 'high'], default='med', help='quality level')

    # Parse the command-line arguments and store them in the variable args
    args = parser.parse_args()

    # Retrieve the values for the input file, output file, speed, and quality from args
    input_file = args.input_file
    output_file= args.out

    # If output_file is not provided, create one with the same name as input_file but with '.mp4' extension
    if (output_file == None):
        output_file= os.path.splitext(input_file)[0]+'.mp4'
        
    # If output_file does not end with '.mp4', append '.mp4' to it
    if '.mp4' not in output_file:
        output_file = output_file + '.mp4'
    
    speed = args.speed
    quality = args.qual

    # If input_file does not exist, raise an exception
    if not os.path.exists(input_file):
        raise FileNotFoundError(f"Input file {input_file} does not exist")
    # If input_file does not end with '.mat', raise an exception
    elif not input_file.endswith('.mat'):
        raise ValueError(f"Input file {input_file} must have the .mat extension")

    # Open the input file using h5py and retrieve N, rows, tmax, and RES arrays
    with h5py.File(input_file, 'r') as f:
        f.keys()

        n = np.array(f.get('N'))
        N = int(n[0])
        r = np.array(f.get('rows'))[0]
        rows = int(r[0])
        tmax = np.array(f.get('tmax'))
        tmax = int(tmax[0])
        data = np.array(f.get('RES'))

    # Define a dictionary with quality levels and corresponding fps and dpi values
    qual_dict = {'low':(10, 100), 'med':(30, 200), "high":(60, 300)}

    # Retrieve fps and dpi values for the given quality level
    fps, dpi = qual_dict[quality]   

    # Calculate the duration of the animation and the number of frames
    duration = tmax / speed
    num_frames = duration * fps

    # Generate the X and Y coordinates for the scatterplot
    radius = np.linspace(100, 150, num = rows)
    radius = radius.reshape(rows,1)
    theta = np.linspace(0, 2*np.pi, num = N, endpoint = False)

    X = np.cos(theta)
    X = np.reshape(X,(1,N))
    Y = np.sin(theta)
    Y = np.reshape(Y,(1,N))

    X_all = np.matmul(radius, X)
    X_all = np.repeat(X_all[:, :, np.newaxis], tmax, axis=2)
    Y_all = np.matmul(radius, Y)
    Y_all = np.repeat(Y_all[:, :, np.newaxis], tmax, axis=2)     

    # Create a new figure with specified size and dpi
    fig,ax = plt.subplots(figsize=(10,10), dpi = dpi)
    ax.axis('off')

    # Generate initial blue and red plots
    scatter1 = ax.scatter(X_all[:,:,0], Y_all[:,:,0], color = "blue")
    scatter2 = ax.scatter(X_all[:,:,0], Y_all[:,:,0], color = "red")

    # Update function for animation
    def update(frame):
        
        # Compute time in order to fit all data in one video of specified length
        t = int(frame*tmax / num_frames)

        # Find where people are standing up
        ind = np.flip(np.argwhere(data[t,:,:] == 1), axis=1)

        # Plot wave
        X_new = X_all[ind[:,0],ind[:,1],t]
        Y_new = Y_all[ind[:,0],ind[:,1],t]   

        scatter2.set_offsets(np.column_stack((X_new, Y_new)))
        
        # Return a tuple of the scatterplots to be updated
        return scatter1, scatter2

    # Generate animation object
    anim = FuncAnimation(fig, update, frames=int(num_frames), interval=int(1000/fps))

    # Save animation object
    anim.save(output_file, writer='ffmpeg')