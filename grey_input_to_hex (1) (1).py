from PIL import Image

# ==========================
# CONFIG
# ==========================
INPUT_IMAGE = "girl.jpg"     # your image file
OUTPUT_HEX  = "grey_input.hex"
WIDTH  = 500
HEIGHT = 500

# ==========================
# LOAD + PROCESS IMAGE
# ==========================
img = Image.open(INPUT_IMAGE).convert("L")  # convert to grayscale
img = img.resize((WIDTH, HEIGHT))           # force 500x500

pixels = list(img.getdata())

# ==========================
# WRITE HEX FILE
# ==========================
with open(OUTPUT_HEX, "w") as f:
    for p in pixels:
        f.write(f"{p:02x}\n")   # 2-digit hex per pixel

print("HEX file generated:", OUTPUT_HEX)
