from itertools import permutations
import math

def generate_permutations(items):
    # permutations
    all_permutations = permutations(items)
    all_list = list(all_permutations)
    print("Initial permutations", len(all_list))
    

    valid_permutations = []
    count = 1
    for perm in all_list:
        print(count, " :", perm)
        count += 1
        group_a_indices = [i for i, item in enumerate(perm) if 'A' in item]
        print("group_a_indices: ", group_a_indices)
        group_b_indices = [i for i, item in enumerate(perm) if 'B' in item]
        print("group_b_indices: ", group_b_indices)
        if tuple(perm[i] for i in group_b_indices) == tuple(items[i] for i in group_b_indices):
            last_b_index = max(group_b_indices)
            
            if all(i > last_b_index for i in group_a_indices):
                valid_permutations.append(perm)
    
    return valid_permutations

def group_by_b_indices(items):
    all_permutations = permutations(items)
    all_list = list(all_permutations)
    
    grouped_permutations = {}
    filtered_permutations = {}
    for perm in all_list:
        group_b_indices = tuple(i for i, item in enumerate(perm) if 'B' in item)
        if group_b_indices not in grouped_permutations:
            grouped_permutations[group_b_indices] = []
        grouped_permutations[group_b_indices].append(perm)

        if group_b_indices[1] <= 2:
            if group_b_indices not in filtered_permutations:
                filtered_permutations[group_b_indices] = []
            filtered_permutations[group_b_indices].append(perm)
    
    return grouped_permutations, filtered_permutations

def print_permutations(permutations):
    for b_indices, perms in permutations.items():
        print("Grouped by B indices:", b_indices)
        print("Permutations:")
        for perm in perms:
            print(perm)
        print("Number of permutations:", len(perms))
        print()

def filter_permutations(filtered_perms):
    final_filter = {}
    for b_indices, perms in filtered_perms.items():
        if b_indices not in final_filter:
            final_filter[b_indices] = []
            jump = math.factorial(4 - b_indices[1])
            for i in perms[::jump]:
                final_filter[b_indices].append(i)
    return final_filter


def final_interleavings(dict1, dict2):
    final_dict = {}
    for key, value in dict1.items():
        if key in dict2:
            final_dict[key] = dict2[key]
        else:
            final_dict[key] = value
    
    last_intls = []

    for key, value in final_dict.items():
        for v in value:
            last_intls.append(v)

    return last_intls

items = ["e1A", "e2A", "e1B", "e2B", "e3A"]

grouped_perms, filtered_perms = group_by_b_indices(items)
filter_permutations(filtered_perms)

print("Final Filtering")
final_filter = filter_permutations(filtered_perms)


print("Final Interleavings")
last_interleavings = final_interleavings(grouped_perms, final_filter)
print(len(last_interleavings))


