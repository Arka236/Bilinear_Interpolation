from PIL import Image

# CONFIG
hex_file = "get_out.hex"
width = 1000
height = 1000

pixels = []

with open(hex_file, "r") as f:
    for line in f:
        line = line.strip()

        # Skip empty or invalid lines
        if not line:
            continue

        try:
            value = int(line, 16)
            if 0 <= value <= 255:
                pixels.append(value)
            else:
                print(f"Out of range value skipped: {line}")
        except ValueError:
            print(f"Invalid hex skipped: {line}")

# Ensure correct pixel count
expected_pixels = width * height

if len(pixels) < expected_pixels:
    print(f"Not enough pixels. Found {len(pixels)}, expected {expected_pixels}")
    pixels += [0] * (expected_pixels - len(pixels))  # pad with black

elif len(pixels) > expected_pixels:
    print(f"Too many pixels. Found {len(pixels)}, trimming to {expected_pixels}")
    pixels = pixels[:expected_pixels]

# Create image
img = Image.new("L", (width, height))  # "L" = grayscale
img.putdata(pixels)

# Save output
img.save("output.png")

print("Image saved as output.png")
