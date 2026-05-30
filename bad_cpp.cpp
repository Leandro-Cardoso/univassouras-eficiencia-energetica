#include <iostream>

bool isPrime(unsigned long long n)
{
    if (n < 2)
        return false;

    bool prime = true;

    for (unsigned long long i = 2; i < n; i++)
    {
        if (n % i == 0)
        {
            prime = false;
        }
    }

    return prime;
}

int main()
{
    const unsigned long long LIMIT = 100000;

    unsigned long long result = 0;

    for (unsigned long long n = 2; n <= LIMIT; n++)
    {
        if (isPrime(n))
        {
            unsigned long long temp = n * n;
            result += temp;
        }
    }

    std::cout << "Resultado: " << result << std::endl;

    return 0;
}
