#include <iostream>
#include <cmath>

bool isPrime(unsigned int n)
{
    if (n < 2)
        return false;

    if (n == 2)
        return true;

    if (n % 2 == 0)
        return false;

    unsigned int limit = static_cast<unsigned int>(std::sqrt(n));

    for (unsigned int i = 3; i <= limit; i += 2)
    {
        if (n % i == 0)
            return false;
    }

    return true;
}

int main()
{
    const unsigned int LIMIT = 100000;

    unsigned long long result = 0;

    for (unsigned int n = 2; n <= LIMIT; ++n)
    {
        if (isPrime(n))
        {
            result += static_cast<unsigned long long>(n) * n;
        }
    }

    std::cout << "Resultado: " << result << '\n';

    return 0;
}
