[Demo video](https://youtu.be/WDrv2BwK9yw)

## Run
1. Download all the required python module in `requirements.txt`
2. Download the model from [release](https://github.com/TKperson/badapplenn/releases/latest) and add the path to to `server/path.conf`
2. Start `main.py` inside the `server` directory
3. Import the Godot 4 project under `badapplenn`
4. Hit run button in Godot

Ignore the "viewport errors" when opening up the project because they are a bug

## About
The role of neural network used in this project is recognizing hand written digits. The input is a 81x81 2D grid. There are a few fully-connected layers trying classify all these input pixels into 10 possible outputs and assign each output with a probability. The outputs are the 10 digits in our number system. Each of the small cube in the series of huge rectangular display is the activation value of a parameter inside the fully-connected layers.

This model is trained using pytorch, a machine learning framework, and exported to onnx. The onnx file then gets used by a backend server written in python that will communicate with godot.

The math behind how fully-connected layers work is a little complicated. If you want to get into the details of how exactly machine “learns” you should go watch some youtube tutorials about back-propagation and statistic modeling.

The tricky part here is embedding an entire video (bad apple in this case) into the weights of the fully-connected layers. Training the model with custom-set limitations was really hard. This model’s accuracy at guessing a human’s handwriting correctly is only about 60% based on the augmented dataset that it was tested on.

This project took 2 weeks to complete
