import os

items = []

for file in os.listdir("."):
    filename = os.fsdecode(file)
    if not filename.endswith(".csv"):
        continue

    with open(filename, "r") as opened_file:
        title = filename.replace(".csv","")
        contents = opened_file.read()
        items.append(f"{ title } = \"\"\"{ contents }\"\"\"")


with open("Examples.elm", "w") as output_file:
    contents = "module Examples exposing (..)"
    for item in items:
        contents += f"\n\n{ item }"

    output_file.write(contents)
