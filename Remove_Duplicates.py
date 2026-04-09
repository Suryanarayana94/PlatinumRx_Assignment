string = input("Enter the string: ").lower()

result = ""
Actual_string = ""

for char in string:
    if char not in Actual_string:
        result += char
        Actual_string += char.lower()

print("unique string:", result)