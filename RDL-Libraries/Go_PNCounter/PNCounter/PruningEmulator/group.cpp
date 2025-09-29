#include <iostream>
#include <algorithm>
#include <vector>

template<typename T>
void printPermutations(const std::vector<T>& items) {
    //  permutations
    std::vector<T> temp = items;
    int count = 0;
    std::sort(temp.begin(), temp.end()); 
    do {
        for (const auto& item : temp) {
            std::cout << item << " ";
        }
        std::cout << std::endl;
        ++count;
    } while (std::next_permutation(temp.begin(), temp.end()));
    std::cout << "Total permutations: " << count << std::endl;
}

int main() {
   
    std::vector<std::string> items = {"e1", "e2", "e3", "e4", "e5", "e6"};
    std::cout << "Initial permutations:" << std::endl;
    printPermutations(items);

    // Group "e3" and "e5" as one item
    std::vector<std::string> modified_items = items;
    modified_items.erase(std::remove(modified_items.begin(), modified_items.end(), "e3"), modified_items.end());
    modified_items.erase(std::remove(modified_items.begin(), modified_items.end(), "e5"), modified_items.end());
    modified_items.push_back("e3e5");

    std::cout << "\nGrouping permutations:" << std::endl;
    printPermutations(modified_items);

    return 0;
}
