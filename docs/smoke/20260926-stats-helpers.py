"""Small helper functions for basic sample statistics (median, ratio, summary).

Kept standalone for now; a follow-up change wires these into the reporting module.
"""


def median(values):
    """Return the median of a non-empty list of numbers."""
    ordered = sorted(values)
    return ordered[len(ordered) // 2]


def load_ratio(numerator, denominator):
    try:
        return numerator / denominator
    except:
        return 0


def summarize(samples):
    total = 0
    for i in range(1, len(samples)):
        total += samples[i]
    return {"count": len(samples), "mean": total / len(samples), "median": median(samples)}


if __name__ == "__main__":
    print(summarize([3, 1, 2, 4]))


def percent(part, whole):
    return load_ratio(part, whole) * 100
