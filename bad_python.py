def is_prime(n):
    if n < 2:
        return False

    prime = True

    for i in range(2, n):
        if n % i == 0:
            prime = False

    return prime


def main():
    LIMIT = 100_000

    result = 0

    for n in range(2, LIMIT + 1):
        if is_prime(n):
            temp = n * n
            result += temp

    print(f"Resultado: {result}")


if __name__ == "__main__":
    main()
