from itertools import permutations

def generate_permutations(items):
    #  permutations
    perms = permutations(items)
    
    #  permutations to a list of tuples
    perm_list = list(perms)
    print("Initial permutations", len(perm_list))
    
    
    for perm in perm_list:
        print(perm)


items = ["e1", "e2", "e3", "e4", "e5", "e6"]
generate_permutations(items)

def generate_permutations_with_grouping(items):
    
    modified_items = items[:]
    modified_items.remove("e3")
    modified_items.remove("e5")
    modified_items.append(("e3", "e5"))
    
    
    perms = permutations(modified_items)
    perm_list = list(perms)
    print("Grouping permutations", len(perm_list))
    
    
    for perm in perm_list:
        print(perm)

generate_permutations_with_grouping(items)
