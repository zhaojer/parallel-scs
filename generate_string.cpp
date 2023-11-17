#include <ctime>
#include <iostream>
#include <unistd.h>

std::string gen_random(const int len) {
    // static const char alphanum[] =
    //     "0123456789"
    //     "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    //     "abcdefghijklmnopqrstuvwxyz";
    static const char alphanum[] = "abcdefghijklmnopqrstuvwxyz";
    std::string tmp_s;
    tmp_s.reserve(len);

    for (int i = 0; i < len; ++i) {
        tmp_s += alphanum[rand() % (sizeof(alphanum) - 1)];
    }

    return tmp_s;
}

int main(int argc, char *argv[]) {
    int length_of_string = 0;
    int num_strings = 1;

    if (argc == 2) {
        length_of_string = atoi(argv[1]);
        if (length_of_string <= 0) {
            std::cerr << "Error: Invalid length of string provided." << std::endl;
            return 1;
        }
    }
    else if (argc == 3) {
        length_of_string = atoi(argv[1]);
        if (length_of_string <= 0) {
            std::cerr << "Error: Invalid length of string provided." << std::endl;
            return 1;
        }
        num_strings = atoi(argv[2]);
        if (num_strings <= 0) {
            std::cerr << "Error: Invalid number of strings provided." << std::endl;
            return 1;
        }
    }
    else {
        std::cerr << "Error: Invalid number of arguments provided." << std::endl;
        std::cerr << "Usage: ./<program name> <length of string> <number of strings = 1(default)>" << std::endl;
        return 1;
    }

    srand((unsigned)time(NULL) * getpid());
    for (int i = 0; i < num_strings; ++i) {
        std::cout << gen_random(length_of_string) << std::endl;
    }
    return 0;
}
