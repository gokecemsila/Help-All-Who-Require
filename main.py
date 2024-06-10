from ultralytics import YOLO

model = YOLO('yolov8n.pt')  # build a new model from YAML

dataset = '/home/meta/Desktop/Ecem/yolo/Dataset/data.yaml' 
results = model.train(data=dataset, epochs=75, imgsz=640, batch=8, name='model3', save=True)
model.val(data=dataset)
