//
//  SimRadioTests.swift
//  SimRadioTests
//
//  Created by Alexey Vorobyov on 30.01.2025.
//

import Foundation
@testable import SimRadio
import Testing

struct SimRadioTests {
    @Test func testMakePlaylist() async throws {
        let series = try JSONDecoder().decode(SimRadio.Series.self, from: radioJson.data(using: .utf8)!)

        let playlistBuilder = PlaylistBuilder(
            baseUrl: URL(string: "/")!,
            commonFiles: series.common.fileGroups,
            station: series.stations.first!
        )

        srand48(Int(100))
        let playlist = try playlistBuilder.makePlaylist(duration: 3 * 60 * 60)

        #expect(playlist.description == playlistForSrand100)
    }
}

// swiftlint:disable line_length file_length
let playlistForSrand100 = #"""
(0.0..5.18): id/id_02.m4a
(5.18..215.38): /radio_01_class_rock/big_log.m4a
(215.38..433.04): /radio_01_class_rock/burning_heart.m4a
  (221.73..227.92): intro/burning_heart_02.m4a
(433.04..457.18): mono_solo/mono_solo_04.m4a
(457.18..723.71): /radio_01_class_rock/black_velvet.m4a
  (465.0..470.95): general/general_02.m4a
  (713.24..715.79): to_news/to_news_03.m4a
(723.71..826.98): news/mono_news_03.m4a
(826.98..833.65): id/id_01.m4a
(833.65..1083.19): /radio_01_class_rock/all_the_things_she_said.m4a
  (841.1..842.5): general/general_04.m4a
  (1073.21..1075.78): to_ad/to_ad_03.m4a
(1083.19..1106.03): adverts/mono_ad008_up_n_atom.m4a
(1106.03..1435.2): /radio_01_class_rock/baker_street.m4a
  (1422.29..1425.42): to_ad/to_ad_01.m4a
(1435.2..1467.45): adverts/mono_ad009_prop_43.m4a
(1467.45..1685.11): /radio_01_class_rock/burning_heart.m4a
  (1676.09..1678.66): to_ad/to_ad_03.m4a
(1685.11..1712.29): adverts/mono_ad002_righteous_slaughter_nuke.m4a
(1712.29..1961.83): /radio_01_class_rock/all_the_things_she_said.m4a
  (1719.66..1723.42): general/general_01.m4a
  (1952.31..1954.41): to_ad/to_ad_02.m4a
(1961.83..1996.87): adverts/mono_ad007_sa_water_power.m4a
(1996.87..2263.4): /radio_01_class_rock/black_velvet.m4a
  (2004.72..2009.54): intro/black_velvet_02.m4a
  (2252.91..2255.48): to_ad/to_ad_03.m4a
(2263.4..2311.03): adverts/mono_ad004_righteous_slaughter_levels.m4a
(2311.03..2528.69): /radio_01_class_rock/burning_heart.m4a
  (2317.37..2323.56): intro/burning_heart_02.m4a
(2528.69..2738.89): /radio_01_class_rock/big_log.m4a
  (2534.92..2537.5): intro/big_log_01.m4a
  (2729.31..2732.68): general/general_03.m4a
(2738.89..2988.43): /radio_01_class_rock/all_the_things_she_said.m4a
(2988.43..3317.6): /radio_01_class_rock/baker_street.m4a
(3317.6..3342.22): mono_solo/mono_solo_03.m4a
(3342.22..3559.88): /radio_01_class_rock/burning_heart.m4a
(3559.88..3770.08): /radio_01_class_rock/big_log.m4a
  (3759.83..3763.89): to_news/to_news_01.m4a
(3770.08..3894.13): news/mono_news_09.m4a
(3894.13..3899.33): id/id_03.m4a
(3899.33..4228.5): /radio_01_class_rock/baker_street.m4a
  (3909.02..3914.97): general/general_02.m4a
  (4216.58..4218.68): to_ad/to_ad_02.m4a
(4228.5..4264.78): adverts/mono_ad006_desert_tourism.m4a
(4264.78..4531.31): /radio_01_class_rock/black_velvet.m4a
(4531.31..4748.97): /radio_01_class_rock/burning_heart.m4a
(4748.97..4766.25): mono_solo/mono_solo_01.m4a
(4766.25..5095.42): /radio_01_class_rock/baker_street.m4a
  (5081.9..5085.66): general/general_01.m4a
(5095.42..5344.96): /radio_01_class_rock/all_the_things_she_said.m4a
  (5334.04..5337.58): to_news/to_news_02.m4a
(5344.96..5447.31): news/mono_news_10.m4a
(5447.31..5453.79): id/id_04.m4a
(5453.79..5663.99): /radio_01_class_rock/big_log.m4a
  (5654.64..5657.78): to_ad/to_ad_01.m4a
(5663.99..5712.31): adverts/ad082_alcoholia.m4a
(5712.31..5978.84): /radio_01_class_rock/black_velvet.m4a
(5978.84..6002.05): mono_solo/mono_solo_02.m4a
(6002.05..6151.89): news/mono_news_02.m4a
(6151.89..6159.25): id/id_05.m4a
(6159.25..6376.91): /radio_01_class_rock/burning_heart.m4a
  (6165.59..6171.78): intro/burning_heart_02.m4a
(6376.91..6587.11): /radio_01_class_rock/big_log.m4a
(6587.11..6916.28): /radio_01_class_rock/baker_street.m4a
  (6596.88..6600.21): general/general_05.m4a
  (6903.93..6906.48): to_news/to_news_03.m4a
(6916.28..7036.47): news/mono_news_05.m4a
(7036.47..7043.14): id/id_01.m4a
(7043.14..7292.68): /radio_01_class_rock/all_the_things_she_said.m4a
  (7050.47..7055.58): intro/all_the_things_she_said_02.m4a
  (7281.76..7285.3): to_news/to_news_02.m4a
(7292.68..7441.09): news/mono_news_01.m4a
(7441.09..7446.29): id/id_03.m4a
(7446.29..7712.82): /radio_01_class_rock/black_velvet.m4a
(7712.82..7737.44): mono_solo/mono_solo_03.m4a
(7737.44..7867.57): news/mono_news_08.m4a
(7867.57..8085.23): /radio_01_class_rock/burning_heart.m4a
  (8075.43..8078.8): general/general_03.m4a
(8085.23..8109.37): mono_solo/mono_solo_04.m4a
(8109.37..8319.57): /radio_01_class_rock/big_log.m4a
  (8115.49..8121.44): general/general_02.m4a
  (8311.22..8313.32): to_ad/to_ad_02.m4a
(8319.57..8351.82): adverts/mono_ad009_prop_43.m4a
(8351.82..8601.36): /radio_01_class_rock/all_the_things_she_said.m4a
  (8359.19..8362.76): intro/all_the_things_she_said_01.m4a
(8601.36..8867.89): /radio_01_class_rock/black_velvet.m4a
  (8609.24..8612.99): general/general_01.m4a
  (8856.85..8859.98): to_ad/to_ad_01.m4a
(8867.89..8919.62): adverts/mono_ad005_sa_tourism_board.m4a
(8919.62..9129.82): /radio_01_class_rock/big_log.m4a
  (9121.47..9123.57): to_ad/to_ad_02.m4a
(9129.82..9184.3): adverts/mono_ad003_righteous_slaughter_russian.m4a
(9184.3..9401.96): /radio_01_class_rock/burning_heart.m4a
  (9190.72..9194.09): general/general_03.m4a
  (9392.38..9395.52): to_ad/to_ad_01.m4a
(9401.96..9438.24): adverts/mono_ad006_desert_tourism.m4a
(9438.24..9687.78): /radio_01_class_rock/all_the_things_she_said.m4a
  (9676.36..9680.42): to_news/to_news_01.m4a
(9687.78..9811.83): news/mono_news_09.m4a
(9811.83..10078.36): /radio_01_class_rock/black_velvet.m4a
  (9819.68..9824.5): intro/black_velvet_02.m4a
(10078.36..10101.57): mono_solo/mono_solo_02.m4a
(10101.57..10311.77): /radio_01_class_rock/big_log.m4a
(10311.77..10329.05): mono_solo/mono_solo_01.m4a
(10329.05..10578.59): /radio_01_class_rock/all_the_things_she_said.m4a
(10578.59..10603.21): mono_solo/mono_solo_03.m4a
(10603.21..10820.87): /radio_01_class_rock/burning_heart.m4a
  (10609.64..10612.97): general/general_05.m4a
  (10812.3..10814.4): to_ad/to_ad_02.m4a

"""#

let radioJson = #"""
{
  "info": {
    "title": "GTA V Radio",
    "logo": "gta_v.png"
  },
  "common": {
    "fileGroups": [
      {
        "tag": "adverts",
        "files": [
          { "path": "common/adverts/ad082_alcoholia.m4a", "duration": 48.32 },
          { "path": "common/adverts/mono_ad001_life_invader.m4a", "duration": 31.05, "audibleDuration": 30.462 },
          { "path": "common/adverts/mono_ad002_righteous_slaughter_nuke.m4a", "duration": 27.93, "audibleDuration": 27.177 },
          { "path": "common/adverts/mono_ad003_righteous_slaughter_russian.m4a", "duration": 55.09, "audibleDuration": 54.48 },
          { "path": "common/adverts/mono_ad004_righteous_slaughter_levels.m4a", "duration": 48.34, "audibleDuration": 47.63 },
          { "path": "common/adverts/mono_ad005_sa_tourism_board.m4a", "duration": 51.73 },
          { "path": "common/adverts/mono_ad006_desert_tourism.m4a", "duration": 37.03, "audibleDuration": 36.286 },
          { "path": "common/adverts/mono_ad007_sa_water_power.m4a", "duration": 35.04 },
          { "path": "common/adverts/mono_ad008_up_n_atom.m4a", "duration": 22.84 },
          { "path": "common/adverts/mono_ad009_prop_43.m4a", "duration": 32.25}
        ]
      },
      {
        "tag": "news",
        "files": [
          { "path": "common/news/mono_news_01.m4a", "duration": 150.21, "audibleDuration": 148.41 },
          { "path": "common/news/mono_news_02.m4a", "duration": 151.38, "audibleDuration": 149.84 },
          { "path": "common/news/mono_news_03.m4a", "duration": 104.79, "audibleDuration": 103.27 },
          { "path": "common/news/mono_news_04.m4a", "duration": 148.35, "audibleDuration": 146.49 },
          { "path": "common/news/mono_news_05.m4a", "duration": 121.83, "audibleDuration": 120.19 },
          { "path": "common/news/mono_news_06.m4a", "duration": 141.74, "audibleDuration": 140.11 },
          { "path": "common/news/mono_news_07.m4a", "duration": 100.26, "audibleDuration": 98.814 },
          { "path": "common/news/mono_news_08.m4a", "duration": 131.75, "audibleDuration": 130.13 },
          { "path": "common/news/mono_news_09.m4a", "duration": 125.59, "audibleDuration": 124.05 },
          { "path": "common/news/mono_news_10.m4a", "duration": 104.22, "audibleDuration": 102.35 }
        ]
      }
    ]
  },
  "stations": [
    {
      "tag": "radio_01_class_rock",
      "info": {
        "title": "Los Santos Rock Radio",
        "genre": "Classic rock, soft rock, pop rock",
        "logo": "radio_01_class_rock.png",
        "dj": "Kenny Loggins"
      },
      "fileGroups": [
        {
          "tag": "track",
          "files": [
            {
              "path": "all_the_things_she_said.m4a",
              "duration": 249.54,
              "attaches": {
                "files": [
                  { "path": "intro/all_the_things_she_said_01.m4a", "duration": 3.94, "audibleDuration": 3.5613 },
                  { "path": "intro/all_the_things_she_said_02.m4a", "duration": 5.11 }
                ]
              }
            },
            {
              "path": "baker_street.m4a",
              "duration": 329.17,
              "attaches": {
                "files": [ { "path": "intro/baker_street_01.m4a", "duration": 3.63 }, { "path": "intro/baker_street_02.m4a", "duration": 6.85 } ]
              }
            },
            {
              "path": "big_log.m4a",
              "duration": 211.03,
              "audibleDuration": 210.2,
              "attaches": {
                "files": [ { "path": "intro/big_log_01.m4a", "duration": 2.58 }, { "path": "intro/big_log_02.m4a", "duration": 6.02 } ]
              }
            },
            {
              "path": "black_velvet.m4a",
              "duration": 266.88,
              "audibleDuration": 266.53,
              "attaches": {
                "files": [ { "path": "intro/black_velvet_01.m4a", "duration": 5.35 }, { "path": "intro/black_velvet_02.m4a", "duration": 4.82} ]
              }
            },
            {
              "path": "burning_heart.m4a",
              "duration": 218.35,
              "audibleDuration": 217.66,
              "attaches": {
                "files": [ { "path": "intro/burning_heart_01.m4a", "duration": 6.49 }, { "path": "intro/burning_heart_02.m4a", "duration": 6.19 } ]
              }
            }
          ]
        },
        {
          "tag": "general",
          "files": [
            { "path": "general/general_01.m4a", "duration": 4.08, "audibleDuration": 3.7533 },
            { "path": "general/general_02.m4a", "duration": 5.95 },
            { "path": "general/general_03.m4a", "duration": 3.37 },
            { "path": "general/general_04.m4a", "duration": 1.4 },
            { "path": "general/general_05.m4a", "duration": 3.33 }
          ]
        },
        {
          "tag": "id",
          "files": [
            { "path": "id/id_01.m4a", "duration": 7.27, "audibleDuration": 6.67 },
            { "path": "id/id_02.m4a", "duration": 5.57, "audibleDuration": 5.1826 },
            { "path": "id/id_03.m4a", "duration": 6.27, "audibleDuration": 5.2 },
            { "path": "id/id_04.m4a", "duration": 7.61, "audibleDuration": 6.48 },
            { "path": "id/id_05.m4a", "duration": 8.49, "audibleDuration": 7.3586 },
          ]
        },
        {
          "tag": "mono_solo",
          "files": [
            { "path": "mono_solo/heists_obh_briefcase_close_mt_thud.m4a", "duration": 24.25, "audibleDuration": 22.93 },
            { "path": "mono_solo/mono_solo_01.m4a", "duration": 18.57, "audibleDuration": 17.278 },
            { "path": "mono_solo/mono_solo_02.m4a", "duration": 24.37, "audibleDuration": 23.209 },
            { "path": "mono_solo/mono_solo_03.m4a", "duration": 26.0, "audibleDuration": 24.617 },
            { "path": "mono_solo/mono_solo_04.m4a", "duration": 25.62, "audibleDuration": 24.14 }
          ]
        },
        {
          "tag": "time_evening",
          "files": [
            { "path": "time_evening/evening_01.m4a", "duration": 3.97, "audibleDuration": 3.66 },
            { "path": "time_evening/evening_02.m4a", "duration": 2.31, "audibleDuration": 1.7906 },
            { "path": "time_evening/evening_03.m4a", "duration": 3.19 }
          ]
        },
        {
          "tag": "time_morning",
          "files": [
            { "path": "time_morning/morning_01.m4a", "duration": 5.17 },
            { "path": "time_morning/morning_02.m4a", "duration": 4.48 },
            { "path": "time_morning/morning_03.m4a", "duration": 3.79 },
          ]
        },
        {
          "tag": "to_adverts",
          "files": [
            { "path": "to_ad/to_ad_01.m4a", "duration": 3.49, "audibleDuration": 3.1346 },
            { "path": "to_ad/to_ad_02.m4a", "duration": 2.1 },
            { "path": "to_ad/to_ad_03.m4a", "duration": 2.57 },
          ]
        },
        {
          "tag": "to_news",
          "files": [ 
            { "path": "to_news/to_news_01.m4a", "duration": 4.06},
            { "path": "to_news/to_news_02.m4a", "duration": 3.54 },
            { "path": "to_news/to_news_03.m4a", "duration": 2.55 },
          ]
        }
      ],
      "playlist": {
        "firstFragment": { "fragmentTag": "id" },
        "fragments": [
          {
            "tag": "id",
            "src": { "type": "group", "groupTag": "id" },
            "nextFragment": [
              { "fragmentTag": "track" }
            ]
          },
          {
            "tag": "track",
            "src": { "type": "group", "groupTag": "track" },
            "nextFragment": [
              { "fragmentTag": "adverts", "probability": 0.357 },
              { "fragmentTag": "monoSolo", "probability": 0.286 },
              { "fragmentTag": "news", "probability": 0.143 },
              { "fragmentTag": "track" }
            ],
            "mixins": {
              "pos": [
                { "tag": "begin", "relativeOffset": 0.03 },
                { "tag": "end", "relativeOffset": 0.97 }
              ],
              "mix": [
                {
                  "tag": "toNews",
                  "src": { "type": "group", "groupTag": "to_news" },
                  "condition": { "type": "nextFragment", "fragmentTag": "news" },
                  "posVariant": [ { "posTag": "end" } ]
                },
                {
                  "tag": "toAdverts",
                  "src": { "type": "group", "groupTag": "to_adverts" },
                  "condition": { "type": "nextFragment", "fragmentTag": "adverts" },
                  "posVariant": [ { "posTag": "end" } ]
                },
                {
                  "tag": "general",
                  "src": { "type": "group", "groupTag": "general" },
                  "condition": { "type": "random", "probability": 0.333 },
                  "posVariant": [ { "posTag": "end" }, { "posTag": "begin" } ]
                },
                {
                  "tag": "intro",
                  "src": { "type": "attach" },
                  "condition": { "type": "random", "probability": 0.333 },
                  "posVariant": [ { "posTag": "begin" }, { "posTag": "end" } ]
                },
                {
                  "tag": "morning",
                  "src": { "type": "group","groupTag": "time_morning" },
                  "condition": {
                    "type": "groupAnd",
                    "condition": [ 
                        { "type": "random", "probability": 0.333 },
                        { "type": "timeInterval", "from": "5:00", "to": "11:00"}
                    ]
                  },
                  "posVariant": [ { "posTag": "end" }, { "posTag": "begin" } ]
                },
                {
                  "tag": "evening",
                  "src": { "type": "group", "groupTag": "time_evening" },
                  "condition": {
                    "type": "groupAnd",
                    "condition": [
                      { "type": "random", "probability": 0.333 },
                      { "type": "timeInterval", "from": "18:00", "to": "24:00" }
                    ]
                  },
                  "posVariant": [ { "posTag": "end" }, { "posTag": "begin" } ]
                }
              ]
            }
          },
          {
            "tag": "monoSolo",
            "src": { "type": "group", "groupTag": "mono_solo"},
            "nextFragment": [
              { "fragmentTag": "news", "probability": 0.4 },
              { "fragmentTag": "track" }
            ]
          },
          {
            "tag": "news",
            "src": { "type": "group","groupTag": "news" },
            "nextFragment": [
              { "fragmentTag": "id", "probability": 0.667 },
              { "fragmentTag": "track" }
            ]
          },
          {
            "tag": "adverts",
            "src": { "type": "group", "groupTag": "adverts" },
            "nextFragment": [ 
                { "fragmentTag": "track" }
            ]
          }
        ]
      }
    }
  ] 
}
"""#
// swiftlint:enable line_length file_length
