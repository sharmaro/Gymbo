//
//  LapDataModel.swift
//  Gymbo
//
//  Created by Rohan Sharma on 11/22/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - LapDataModel
struct LapDataModel {
    var laps: [Lap]?
    var previousLap: Lap?
    var fastestLap: Lap?
    var slowestLap: Lap?
}

// MARK: - Structs/Enums
private extension LapDataModel {
    struct Constants {
        static let cellHeight = CGFloat(50)
    }
}

// MARK: - Funcs
extension LapDataModel {
    mutating func newLap(minutes: Int, seconds: Int, centiSeconds: Int) -> Lap {
        var lap = Lap(minutes: minutes,
                      seconds: seconds,
                      centiSeconds: centiSeconds)

        if let previousLap = previousLap {
            lap.minutes = abs(previousLap.minutes - minutes)
            lap.seconds = abs(previousLap.seconds - seconds)
            lap.centiSeconds = abs(previousLap.centiSeconds - centiSeconds)
        }

        if let fastestLap = fastestLap {
            if lap.totalTime <= fastestLap.totalTime {
                self.fastestLap = lap
            }
        } else {
            self.fastestLap = lap
        }

        if let slowestLap = slowestLap {
            if lap.totalTime >= slowestLap.totalTime {
                self.slowestLap = lap
            }
        } else {
            self.slowestLap = lap
        }
        return lap
    }

    // MARK: - UITableViewCells
    private func getStopWatchCell(in tableView: UITableView,
                                  for indexPath: IndexPath) -> StopwatchTVCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: StopwatchTVCell.reuseIdentifier,
            for: indexPath) as? StopwatchTVCell else {
            fatalError("Could not dequeue \(StopwatchTVCell.reuseIdentifier)")
        }

        guard let laps = laps else {
            fatalError("Laps array is nil")
        }

        let lap = laps[indexPath.row]
        cell.configure(descriptionText: "Lap \(laps.count - indexPath.row)", valueText: lap.text)

        if laps.count > 2 {
            cell.checkLapComparison(timeToCheck: lap.totalTime,
                                    fastestTime: fastestLap?.totalTime ?? 0,
                                    slowestTime: slowestLap?.totalTime ?? 0)
        }
        return cell
    }
}

// MARK: - UITableViewDataSource
extension LapDataModel {
    var numberOfSections: Int {
        1
    }

    func numberOfRows(in section: Int) -> Int {
        laps?.count ?? 0
    }

    func cellForRow(in tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        getStopWatchCell(in: tableView, for: indexPath)
    }

    func lap(at index: Int) -> Lap? {
        laps?[index]
    }

    func heightForRow(at indexPath: IndexPath) -> CGFloat {
        Constants.cellHeight
    }
}
