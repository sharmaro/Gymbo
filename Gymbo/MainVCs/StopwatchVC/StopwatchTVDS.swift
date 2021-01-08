//
//  StopwatchTVDS.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/28/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class StopwatchTVDS: NSObject {
    var centiSecInt = 0
    var secInt = 0
    var minInt = 0

    private var laps = [Lap]()
    private var timeWhenLapped = [Lap]()
    private var fastestLap: Lap?
    private var slowestLap: Lap?

    private let defaults = UserDefaults.standard

    private weak var listDataSource: ListDataSource?

    init(listDataSource: ListDataSource?) {
        super.init()

        self.listDataSource = listDataSource
    }
}

// MARK: - Structs/Enums
private extension StopwatchTVDS {
    struct Constants {
        static let LAPS_KEY = "laps"

        static let CENTISECONDS_KEY = "centiseconds"
        static let SECONDS_KEY = "seconds"
        static let MINUTES_KEY = "minutes"
    }
}

// MARK: - Funcs
extension StopwatchTVDS {
    private func getLabelColor(timeToCheck: Int,
                               fastestTime: Int,
                               slowestTime: Int) -> UIColor {
        var color = UIColor.primaryText
        if timeToCheck <= fastestTime {
            color = .systemGreen
        } else if timeToCheck >= slowestTime {
            color = .systemRed
        }
        return color
    }

    private func loadLaps() {
        let decoder = JSONDecoder()
        if let data = defaults.data(forKey: Constants.LAPS_KEY),
            let allLaps = try? decoder.decode([[Lap?]].self, from: data) {
            guard allLaps.count == 3 else {
                return
            }

            laps = allLaps[0].map { $0 ?? Lap() }
            timeWhenLapped = allLaps[1].map { $0 ?? Lap() }
            fastestLap = allLaps[2][0]
            slowestLap = allLaps[2][1]
        }
        listDataSource?.reloadData()
    }

    private func loadTimerValues() {
        if let timeDictionary = defaults.object(
            forKey: UserDefaultKeys.STOPWATCH_TIME_DICTIONARY) as? [String: Int] {
            centiSecInt = timeDictionary[Constants.CENTISECONDS_KEY] ?? 0
            secInt = timeDictionary[Constants.SECONDS_KEY] ?? 0
            minInt = timeDictionary[Constants.MINUTES_KEY] ?? 0
        }

        var oldTimeInCentiSecs = 0
        oldTimeInCentiSecs += centiSecInt
        oldTimeInCentiSecs += (secInt * 100)
        oldTimeInCentiSecs += (minInt * 6000)

        // Converting seconds from date to centiseconds
        if let stateRawValue = defaults.object(
            forKey: UserDefaultKeys.STOPWATCH_STATE) as? Int,
           stateRawValue == 2,
           let date = defaults.object(forKey: UserDefaultKeys.STOPWATCH_DATE) as? Date {
            let centiSecElapsed = Int(Date().timeIntervalSince(date) * 100) + oldTimeInCentiSecs
            centiSecInt = centiSecElapsed % 100

            let totalSeconds = centiSecElapsed / 100
            secInt = totalSeconds % 60
            minInt = totalSeconds / 60
        }
    }

    private func saveLaps() {
        let encoder = JSONEncoder()
        let allLaps: [[Lap?]] = [
            laps,
            timeWhenLapped,
            [fastestLap, slowestLap]
        ]

        if let encodedData = try? encoder.encode(allLaps) {
            defaults.set(encodedData, forKey: Constants.LAPS_KEY)
        }
    }

    private func saveTimerValues(stateRawValue: Int) {
        let timeDictionary: [String: Int] = [
            Constants.CENTISECONDS_KEY: centiSecInt,
            Constants.SECONDS_KEY: secInt,
            Constants.MINUTES_KEY: minInt
        ]

        defaults.set(Date(), forKey: UserDefaultKeys.STOPWATCH_DATE)
        defaults.set(stateRawValue, forKey: UserDefaultKeys.STOPWATCH_STATE)
        defaults.set(timeDictionary, forKey: UserDefaultKeys.STOPWATCH_TIME_DICTIONARY)
    }

    func add(lap: Lap) {
        var lapCopy = lap
        let lapTimeWhenLapped = lap

        if !timeWhenLapped.isEmpty {
            let lastLap = timeWhenLapped[0]
            lapCopy.minutes = abs(lastLap.minutes - lap.minutes)
            lapCopy.seconds = abs(lastLap.seconds - lap.seconds)
            lapCopy.centiSeconds = abs(lastLap.centiSeconds - lap.centiSeconds)
        }
        timeWhenLapped.insert(lapTimeWhenLapped, at: 0)

        if let fastestLap = fastestLap {
            if lapCopy.totalTime <= fastestLap.totalTime {
                self.fastestLap = lapCopy
            }
        } else {
            self.fastestLap = lapCopy
        }

        if let slowestLap = slowestLap {
            if lapCopy.totalTime >= slowestLap.totalTime {
                self.slowestLap = lapCopy
            }
        } else {
            self.slowestLap = lapCopy
        }
        laps.insert(lapCopy, at: 0)
    }

    func saveData(stateRawValue: Int) {
        saveLaps()
        saveTimerValues(stateRawValue: stateRawValue)
    }

    func loadData() {
        loadLaps()
        loadTimerValues()
    }

    func clearLapInfo() {
        laps.removeAll()
        timeWhenLapped.removeAll()
        fastestLap = nil
        slowestLap = nil
    }
}

// MARK: - UITableViewDataSource
extension StopwatchTVDS: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        laps.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: StopwatchTVCell.reuseIdentifier,
            for: indexPath) as? StopwatchTVCell else {
            fatalError("Could not dequeue \(StopwatchTVCell.reuseIdentifier)")
        }

        let lap = laps[indexPath.row]
        cell.configure(descriptionText: "Lap \(laps.count - indexPath.row)", valueText: lap.text)

        if laps.count > 2 {
            let color = getLabelColor(timeToCheck: lap.totalTime,
                                      fastestTime: fastestLap?.totalTime ?? 0,
                                      slowestTime: slowestLap?.totalTime ?? 0)
            cell.updateColors(color: color)
        } else {
            cell.updateColors(color: .primaryText)
        }
        return cell
    }
}
