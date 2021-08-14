from sys import stdin

FORMATTER_STR = '032b'

def main():
    for line in stdin:
        print(format(int('0x' + line, 16), FORMATTER_STR))

if __name__ == '__main__':
    main()
