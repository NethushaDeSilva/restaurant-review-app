"""Generates bordered placeholder images for screenshots that do not exist yet."""
from PIL import Image, ImageDraw, ImageFont
import os

OUT = os.path.join(os.path.dirname(__file__), "screenshots", "_placeholders")
os.makedirs(OUT, exist_ok=True)

def font(size):
    try:
        return ImageFont.truetype("arial.ttf", size)
    except Exception:
        return ImageFont.load_default()

def make_box(filename, width, height, label, sub):
    img = Image.new("RGB", (width, height), "white")
    d = ImageDraw.Draw(img)
    d.rectangle([2, 2, width - 3, height - 3], outline=(120, 120, 120), width=2)
    f1 = font(20)
    f2 = font(15)
    text1 = "SCREENSHOT TO BE INSERTED"
    text2 = sub
    text3 = label
    for i, (t, f, dy) in enumerate([
        (text1, f1, -40),
        (text2, f2, 0),
        (text3, f2, 30),
    ]):
        bbox = d.textbbox((0, 0), t, font=f)
        tw = bbox[2] - bbox[0]
        th = bbox[3] - bbox[1]
        d.text(((width - tw) / 2, (height - th) / 2 + dy), t, fill=(90, 90, 90), font=f)
    img.save(os.path.join(OUT, filename))

# phone portrait ~ 9:19.5
make_box("phone_login.png", 585, 1267, "login.png", "Login screen")
make_box("phone_register.png", 585, 1267, "register.png", "Register screen")
make_box("phone_home.png", 585, 1267, "home.png", "Home tab")
make_box("phone_restaurants_portrait.png", 585, 1267, "restaurants_portrait.png", "Restaurants tab, portrait")
make_box("phone_restaurant_detail.png", 585, 1267, "restaurant_detail.png", "Restaurant detail screen")
make_box("phone_add_review.png", 585, 1267, "add_review.png", "Add/edit review form")
make_box("phone_my_reviews.png", 585, 1267, "my_reviews.png", "My Reviews tab")
make_box("phone_my_restaurants.png", 585, 1267, "my_restaurants.png", "My Restaurants screen")
make_box("phone_add_restaurant.png", 585, 1267, "add_restaurant.png", "Add/edit restaurant form")
make_box("phone_profile.png", 585, 1267, "profile.png", "Profile tab")
make_box("phone_dark_home.png", 585, 1267, "dark_home.png", "Home tab, dark mode")
make_box("phone_location_denied.png", 585, 1267, "location_denied.png", "Location permission denied state")

# phone landscape ~ 19.5:9
make_box("phone_restaurants_landscape.png", 1267, 585, "restaurants_landscape.png", "Restaurants tab, landscape")
make_box("phone_dark_restaurants.png", 1267, 585, "dark_restaurants.png", "Restaurants tab, dark mode")

# tablet ~ 4:3 and 3:4
make_box("tablet_portrait.png", 900, 1200, "tablet_portrait.png", "Tablet AVD, portrait")
make_box("tablet_landscape.png", 1200, 900, "tablet_landscape.png", "Tablet AVD, landscape")

# firebase console, wide screenshot
make_box("firebase_console.png", 1400, 800, "firebase_console.png", "Firebase console, live data")

print("done")
