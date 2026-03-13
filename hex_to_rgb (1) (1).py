from PIL import Image

# CONFIG
hex_file = "input.hex"
width = 1000
height = 1000

pixels = []

with open(hex_file, "r") as f:
    for line in f:
        line = line.strip()

        # Skip empty lines
        if not line:
            continue

        # Expecting RRGGBB format
        if len(line) != 6:
            print(f"Invalid length skipped: {line}")
            continue

        try:
            r = int(line[0:2], 16)
            g = int(line[2:4], 16)
            b = int(line[4:6], 16)
            pixels.append((r, g, b))
        except ValueError:
            print(f"Invalid hex skipped: {line}")

# Ensure correct pixel count
expected_pixels = width * height

if len(pixels) < expected_pixels:
    print("Not enough pixels, padding with black")
    pixels += [(0, 0, 0)] * (expected_pixels - len(pixels))

elif len(pixels) > expected_pixels:
    print("Too many pixels, trimming")
    pixels = pixels[:expected_pixels]

# Create RGB image
img = Image.new("RGB", (width, height))
img.putdata(pixels)

# Save output
img.save("output_rgb.png")

print("RGB image saved as output_rgb.png")

