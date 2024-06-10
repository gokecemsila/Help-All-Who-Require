import os
from PIL import Image

# Define the paths to your dataset and labels
#high_class_path = '/home/meta/Desktop/Ecem/Dataset/HValidate/Images'
low_class_path = '/home/meta/Desktop/Ecem/Dataset/LTrain/Images'
label_path = '/home/meta/Desktop/Ecem/Dataset/LValidate/Labels'

# Create the label directory if it does not exist
os.makedirs(label_path, exist_ok=True)

def create_yolo_label(image_path, class_index, label_path):
    # Load the image
    with Image.open(image_path) as img:
        width, height = img.size

    # Create a label file for the image
    label_file = os.path.join(label_path, os.path.splitext(os.path.basename(image_path))[0] + '.txt')
    with open(label_file, 'w') as f:
        # Bounding box covering the entire image
        x_center = 0.5  # Center x (normalized)
        y_center = 0.5  # Center y (normalized)
        obj_width = 1.0  # Object width (normalized)
        obj_height = 1.0 # Object height (normalized)
        
        f.write(f"{class_index} {x_center} {y_center} {obj_width} {obj_height}\n")

def process_class_images(class_path, class_index, label_path):
    for image_name in os.listdir(class_path):
        image_path = os.path.join(class_path, image_name)
        if os.path.isfile(image_path):
            create_yolo_label(image_path, class_index, label_path)

# Process images in the high class folder
#process_class_images(high_class_path, 0, label_path)

# Process images in the low class folder
process_class_images(low_class_path, 1, label_path)

print("Label files created successfully.")
