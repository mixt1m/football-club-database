import csv
from datetime import datetime, timedelta
from pathlib import Path


ROW_COUNT = 1_000_000
CITIES = [
    "Moscow",
    "Saint Petersburg",
    "Kazan",
    "Novosibirsk",
    "Yekaterinburg",
    "Sochi",
    "Vladivostok",
]


def main() -> None:
    output_path = Path(__file__).resolve().parent.parent / "data" / "trips.csv"
    output_path.parent.mkdir(parents=True, exist_ok=True)

    base_time = datetime(2024, 1, 1, 0, 0, 0)

    with output_path.open("w", newline="", encoding="utf-8") as csv_file:
        writer = csv.writer(csv_file)
        writer.writerow(["trip_id", "start_time", "end_time", "distance_km", "city"])

        for i in range(ROW_COUNT):
            start_time = base_time + timedelta(seconds=i % 31_536_000)
            duration_sec = 300 + (i * 37 % 7200)
            end_time = start_time + timedelta(seconds=duration_sec)
            distance_km = round(1 + ((i * 17) % 5000) / 100.0, 2)
            city = CITIES[i % len(CITIES)]

            writer.writerow(
                [
                    i + 1,
                    start_time.strftime("%Y-%m-%d %H:%M:%S"),
                    end_time.strftime("%Y-%m-%d %H:%M:%S"),
                    distance_km,
                    city,
                ]
            )


if __name__ == "__main__":
    main()
