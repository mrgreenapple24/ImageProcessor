# generate_test_image.py
import numpy as np
from PIL import Image

def generate_test_image(width=640, height=480):
    # Create gradient image
    image = np.zeros((height, width), dtype=np.uint8)
    
    for y in range(height):
        for x in range(width):
            # Horizontal gradient
            image[y, x] = (x * 255) // width
    
    # Save as raw file
    image.tofile('test_image.raw')
    
    # Also save as PNG for viewing
    img = Image.fromarray(image, mode='L')
    img.save('test_image.png')
    
    print(f"Generated test image: {width}x{height}")
    print("Files created: test_image.raw, test_image.png")

if __name__ == "__main__":
    generate_test_image(640, 480)