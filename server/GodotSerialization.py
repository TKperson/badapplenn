"""Converts python objects to godot variants

based on: https://docs.godotengine.org/en/stable/tutorials/io/binary_serialization_api.html
"""
import struct

class Variant:
    type: bytes = None
    value: bytes = None

    def int_to_bytes(self, value: int, byte_size):
        return value.to_bytes(byte_size, "little")

    def __init__(self, type: int, value: int = None, byte_size: int = 4):
        self.type = self.int_to_bytes(type, byte_size)
        if value is not None:
            self.value = self.int_to_bytes(value, byte_size)

    def serialize(self):
        out = self.type + self.value
        return out

class GodotArray(Variant):
    def __init__(self, length: int, values: list[Variant]):
        super().__init__(28, length)
        self.values = values

    def serialize(self):
        out = self.type + self.value
        for value in self.values:
            out += value.serialize()
        return out

    def __len__(self):
        return len(self.values)
    
    def __getitem__(self, index):
        return self.values[index]

class GodotInt(Variant):
    def __init__(self, value):
        super().__init__(2, value)

class GodotVector2(Variant):
    def __init__(self, x: float, y: float):
        super().__init__(5)
        self.value = struct.pack("f", x) + struct.pack("f", y)

    def __repr__(self) -> str:
        x = struct.unpack("f", self.value[0:4])[0]
        y = struct.unpack("f", self.value[4:8])[0]
        return (f"GodotVector2({x}, {y})")