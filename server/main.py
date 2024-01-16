import flask
from model import Model
import numpy as np

app = flask.Flask(__name__)

print("loading model")
model = Model(
    onnx_path='/home/kanna/ml/models/badapple_in_nn/badapple_in_nn.onnx', 
    display_size=(360 // 3, 480 // 3),
    interpreter_layers=10,
)

all_frames = np.identity(81 * 81).astype(np.float32)
all_frames = all_frames.reshape(81 * 81, 81, 81)

print("generating model activations for badapple frames")
activations = model.predict_with_return_activation(all_frames)
original_shapes = model.serialize_original_shapes(activations)
scaled_ouputs = model.serialize_to_godot_bytes(activations)

@app.get("/shapes")
def get_shapes():
    return original_shapes

@app.get("/activations")
def get_activations():
    return scaled_ouputs

@app.post("/activations")
def post_activations():
    content = flask.request.json
    image = np.array(content).astype(np.float32)

    image = np.expand_dims(image, axis=0)
    activations = model.predict_with_return_activation(image)
    scaled_ouputs = model.serialize_to_godot_bytes(activations)
    return scaled_ouputs

if __name__ == '__main__':
    app.run(host='0.0.0.0')