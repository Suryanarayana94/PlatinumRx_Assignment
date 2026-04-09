no_of_minutes = int(input("Enter number of minutes: "))

def convert_minutes(minutes):
    hours = minutes // 60
    mins = minutes % 60
    result = ""

    if hours > 0:
        result += f"{hours} hr" if hours == 1 else f"{hours} hrs"

    if mins > 0:
        if result:
            result += " "
        result +=  f"{mins} minute" if mins == 1 else f"{mins} minutes"
    
    return result if result else "0 minutes"

print(convert_minutes(no_of_minutes))