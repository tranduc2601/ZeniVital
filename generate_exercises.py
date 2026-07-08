import urllib.request
import json
import re

url = "https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/dist/exercises.json"
req = urllib.request.urlopen(url)
data = json.loads(req.read().decode('utf-8'))

exercises = data[:55]

dart_exercises = []
for ex in exercises:
    ex_id = ex.get('id', '').replace('-', '_').replace(' ', '_').replace('/', '_')
    name = ex.get('name', '').replace("'", "\\'")
    target_muscle = ex.get('primaryMuscles', ['Unknown'])[0].capitalize()
    difficulty = ex.get('level', 'Beginner').capitalize()
    equipment = ex.get('equipment', 'Bodyweight')
    if equipment: equipment = equipment.capitalize()
    
    images = ex.get('images', [])
    image_url = ""
    if images:
        image_url = f"https://cdn.jsdelivr.net/gh/yuhonas/free-exercise-db@main/exercises/{images[0]}"
    
    instructions = ex.get('instructions', [])
    description = ""
    if instructions:
        description = instructions[0].replace("'", "\\'")
    
    steps = [s.replace("'", "\\'") for s in instructions]
    
    images_list = [f"https://cdn.jsdelivr.net/gh/yuhonas/free-exercise-db@main/exercises/{img}" for img in images]
    
    dart_code = f"""    Exercise(
      id: '{ex_id}',
      name: '{name}',
      targetMuscle: '{target_muscle}',
      difficulty: '{difficulty}',
      equipment: '{equipment}',
      imageUrl: '{image_url}',
      gifUrl: '',
      description: '{description}',
      isPremium: false,
      steps: {steps},
      images: {images_list},
    ),"""
    # Replace brackets with Dart brackets where necessary, wait lists are printed nicely with json
    
    dart_exercises.append(dart_code)

exercises_str = "\n".join(dart_exercises)

dart_file_path = "lib/data/api/static_data.dart"
with open(dart_file_path, "r", encoding="utf-8") as f:
    content = f.read()

# Replace the old exercises list
pattern = re.compile(r'static const List<Exercise> exercises = \[(.*?)\];', re.DOTALL)
new_content = pattern.sub(f'static const List<Exercise> exercises = [\n{exercises_str}\n  ];', content)

with open(dart_file_path, "w", encoding="utf-8") as f:
    f.write(new_content)

print("Generated 55 exercises and updated static_data.dart successfully.")
