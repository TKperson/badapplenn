from GodotSerialization import *
import onnx
import onnxruntime as ort
import numpy as np
from collections import OrderedDict
import math

class Model:
    def __init__(
            self, 
            onnx_path: str,
            display_size: tuple[int, int],
            interpreter_layers: int,
        ):
        self.onnx_path = onnx_path
        self.display_size = display_size
        self.interpreter_layers = interpreter_layers
        self.total_frames = 81 * 81

        self.load_model()


    def load_model(self):
        ort_session = ort.InferenceSession(self.onnx_path)
        org_outputs = [x.name for x in ort_session.get_outputs()]

        model = onnx.load(self.onnx_path)
        for node in model.graph.node:
            for output in node.output:
                if output not in org_outputs:
                    model.graph.output.extend([onnx.ValueInfoProto(name=output)])

        self.ort_session = ort.InferenceSession(model.SerializeToString())
        self.layer_output_names = [x.name for x in self.ort_session.get_outputs()]
        self.layer_output_names.remove("output")
        self.layer_output_names.remove("/Constant_output_0")
        self.layer_output_names.remove("/hidden_layers/hidden_layers.0/relu/Relu_output_0")
        self.layer_output_names.remove("/hidden_layers/hidden_layers.1/relu/Relu_output_0")
        self.layer_output_names.remove("/hidden_layers/hidden_layers.2/relu/Relu_output_0")
        #self.layer_output_names.remove("/Reshape_output_0")

    def predict_with_return_activation(self, x):
        ort_outs = self.ort_session.run(self.layer_output_names, {"input": x} )
        ort_outs = OrderedDict(zip(self.layer_output_names, ort_outs))
        return ort_outs

    def min_max_normalize(self, x):
        temp = (x.max() - x.min())
        if temp == 0:
            return x
        return (x - x.min()) / (x.max() - x.min())

    def softmax(self, x: np.ndarray, dim: int) -> np.ndarray:
        return np.exp(x) / np.sum(np.exp(x), axis=dim, keepdims=True)

    def calculate_rectangle(self, area: int) -> tuple[float, float]:
        squared_area = area ** 0.5
        if squared_area.is_integer():
            return (squared_area, squared_area)
        
        for i in range(math.floor(squared_area), 0, -1):
            for j in range(math.ceil(squared_area), area + 1):
                if i * j == area:
                    return (j, i)
                
                if i * j > area:
                    break

    def serialize_original_shapes(self, outputs: OrderedDict) -> bytes:
        original_shapes = []
        for layer_output in outputs.values():
            _, layer_shape = layer_output.shape
            original_shapes.append(
                GodotVector2(*self.calculate_rectangle(layer_shape))
            )

        original_shapes[-1] = GodotVector2(10, 1)

        original_shapes[1] = GodotVector2(
            self.display_size[1] + 2 * self.interpreter_layers,
            self.display_size[0] + 2 * self.interpreter_layers, 
        )

        original_shapes = GodotArray(len(outputs), original_shapes)
        return original_shapes.serialize()
        

    def serialize_to_godot_bytes(self, outputs: OrderedDict) -> bytes:
        scaled_ouputs = bytearray()

        all_frames = outputs.values()

        for all_layers in zip(*all_frames):
            for i, layer_output in enumerate(all_layers):
                if i == len(all_layers) - 1:
                    scaled_ouputs += (self.softmax(layer_output, dim=0) * 255).astype(np.uint8).tobytes()
                    break

                scaled_ouputs += (self.min_max_normalize(layer_output) * 255).astype(np.uint8).tobytes()

        return bytes(scaled_ouputs)

if __name__ == '__main__':
    model_path = '/home/kanna/ml/models/badapple_in_nn/badapple_in_nn.onnx'
    model = Model(
        onnx_path=model_path, 
        display_size=(360 // 3, 480 // 3),
        interpreter_layers=10,
    )

    sample_input = np.random.rand(3, 81, 81).astype(np.float32)
    outputs = model.predict_with_return_activation(sample_input)
    scaled_ouputs = model.serialize_to_godot_bytes(outputs)
    original_shapes = model.serialize_original_shapes(outputs)
    print(original_shapes)
