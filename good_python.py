from math import isqrt


def is_prime(n):
    if n < 2:
        return False

    if n == 2:
        return True

    if n % 2 == 0:
        return False

    limit = isqrt(n)

    for i in range(3, limit + 1, 2):
        if n % i == 0:
            return False

    return True


def main():
    LIMIT = 100_000

    result = 0

    for n in range(2, LIMIT + 1):
        if is_prime(n):
            result += n * n

    print(f"Resultado: {result}")


if __name__ == "__main__":
    main()
