"""
Generate a realistic Moroccan CIN (ID Card) image for testing OCR
"""
from PIL import Image, ImageDraw, ImageFont
import random

def create_cin_card(filename="test_cin_AB123456.jpg", cin_number="AB123456"):
    """Create a realistic Moroccan CIN card image"""
    
    # Create image (Moroccan CIN dimensions approximately 85.60 × 53.98 mm)
    # Using 300 DPI: 1011 x 638 pixels
    width, height = 1011, 638
    
    # Create base image with gradient background
    img = Image.new('RGB', (width, height), color=(200, 220, 240))
    draw = ImageDraw.Draw(img)
    
    # Add background pattern (simulating security features)
    for i in range(0, width, 30):
        draw.line([(i, 0), (i, height)], fill=(210, 225, 245), width=1)
    for i in range(0, height, 30):
        draw.line([(0, i), (width, i)], fill=(210, 225, 245), width=1)
    
    # Try to use a basic font, fallback to default if not available
    try:
        title_font = ImageFont.truetype("arial.ttf", 28)
        header_font = ImageFont.truetype("arialbd.ttf", 24)
        large_font = ImageFont.truetype("arialbd.ttf", 36)
        normal_font = ImageFont.truetype("arial.ttf", 22)
        small_font = ImageFont.truetype("arial.ttf", 18)
    except:
        # Fallback to default font
        title_font = ImageFont.load_default()
        header_font = ImageFont.load_default()
        large_font = ImageFont.load_default()
        normal_font = ImageFont.load_default()
        small_font = ImageFont.load_default()
    
    # Add header with Moroccan flag colors (red background)
    draw.rectangle([(0, 0), (width, 80)], fill=(193, 39, 45))
    
    # Add "ROYAUME DU MAROC" text
    draw.text((width//2, 25), "ROYAUME DU MAROC", fill='white', 
              font=header_font, anchor='mm')
    draw.text((width//2, 55), "Carte Nationale d'Identité", fill='white', 
              font=small_font, anchor='mm')
    
    # Add photo placeholder
    photo_x, photo_y = 50, 120
    photo_size = 180
    draw.rectangle([(photo_x, photo_y), (photo_x + photo_size, photo_y + photo_size)], 
                   fill=(180, 180, 180), outline=(100, 100, 100), width=3)
    draw.text((photo_x + photo_size//2, photo_y + photo_size//2), "PHOTO", 
              fill=(150, 150, 150), font=normal_font, anchor='mm')
    
    # Add CIN Information
    info_x = 270
    y_start = 130
    line_height = 50
    
    # CIN Number (most important for OCR)
    draw.rectangle([(info_x - 10, y_start - 10), (width - 50, y_start + 40)], 
                   fill=(255, 255, 220), outline=(193, 39, 45), width=2)
    draw.text((info_x, y_start), f"N°: {cin_number}", fill='black', 
              font=large_font)
    
    # Personal Information
    y = y_start + line_height + 20
    
    fields = [
        ("Nom:", "BENALI"),
        ("Prénom:", "Ahmed"),
        ("Date de naissance:", "15/03/1990"),
        ("Lieu de naissance:", "Casablanca"),
        ("Sexe:", "M"),
    ]
    
    for label, value in fields:
        draw.text((info_x, y), label, fill=(80, 80, 80), font=small_font)
        draw.text((info_x + 200, y), value, fill='black', font=normal_font)
        y += 45
    
    # Add validity date at bottom
    draw.text((info_x, height - 60), "Validité: 15/03/2030", 
              fill=(80, 80, 80), font=small_font)
    
    # Add barcode placeholder at bottom
    barcode_y = height - 50
    for i in range(50, width - 50, 8):
        bar_width = random.choice([2, 3, 4, 5])
        draw.rectangle([(i, barcode_y), (i + bar_width, barcode_y + 40)], 
                       fill='black')
    
    # Add some noise to simulate photo quality
    pixels = img.load()
    for _ in range(500):
        x = random.randint(0, width - 1)
        y = random.randint(0, height - 1)
        noise_color = tuple([min(255, max(0, c + random.randint(-30, 30))) 
                            for c in pixels[x, y]])
        pixels[x, y] = noise_color
    
    # Save image
    img.save(filename, 'JPEG', quality=85)
    print(f"✅ Created CIN image: {filename}")
    print(f"   CIN Number: {cin_number}")
    return filename

def create_multiple_cins():
    """Create multiple test CIN cards"""
    test_cins = [
        "AB123456",
        "CD789012", 
        "EF345678",
        "GH901234",
    ]
    
    for cin in test_cins:
        create_cin_card(f"test_cin_{cin}.jpg", cin)

if __name__ == "__main__":
    print("🔵 Generating test CIN card images...")
    create_multiple_cins()
    print("\n✅ All CIN test images generated successfully!")
    print("\nUse these images to test CIN OCR:")
    print("  - test_cin_AB123456.jpg")
    print("  - test_cin_CD789012.jpg")
    print("  - test_cin_EF345678.jpg")
    print("  - test_cin_GH901234.jpg")
