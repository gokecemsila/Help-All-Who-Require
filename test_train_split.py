import os
import shutil
import random

def split_dataset(dataset_path, train_output_path, val_output_path, train_ratio=0.8, val_ratio=0.2):
    # Ensure the ratios sum up to 1.0
    assert train_ratio + val_ratio == 1.0, "Ratios must sum up to 1.0"

    os.makedirs(train_output_path, exist_ok=True)
    os.makedirs(val_output_path, exist_ok=True)

    images = [f for f in os.listdir(dataset_path) if os.path.isfile(os.path.join(dataset_path, f))]

    random.shuffle(images)

    train_end = int(train_ratio * len(images))

    train_images = images[:train_end]
    val_images = images[train_end:]

    # Move files to the respective directories
    for image in train_images:
        image_path = os.path.join(dataset_path, image)
        shutil.copy(image_path, os.path.join(train_output_path, image))

    for image in val_images:
        image_path = os.path.join(dataset_path, image)
        shutil.copy(image_path, os.path.join(val_output_path, image))

dataset_path = '/home/meta/Desktop/Ecem/Dataset/Low'
train_output_path = '/home/meta/Desktop/Ecem/Dataset/LTrain/Images'
val_output_path = '/home/meta/Desktop/Ecem/Dataset/LValidate/Images'
split_dataset(dataset_path, train_output_path, val_output_path)

print("Dataset split into training and validation sets.")
