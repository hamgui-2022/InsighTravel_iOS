//
//  ContentView.swift
//  TravelAgent
//
//  Created by 이재혁 on 3/17/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        mainLayout
    }

    private var mainLayout: some View {
        VStack(alignment: .leading, spacing: 0) {
            chatSection
            inputBar
        }
        .frame(width: 390)
        .background(Color(red: 0.95, green: 0.95, blue: 0.97))
    }

    private var chatSection: some View {
          ZStack() {
            VStack(alignment: .leading, spacing: 24) {
              HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                  HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 0) {

                    }
                  }
                  .frame(width: 32, height: 32)
                  .background(Color(red: 0, green: 0.48, blue: 1))
                  .cornerRadius(9999)
                }
                .padding(EdgeInsets(top: 4, leading: 0, bottom: 0, trailing: 0))
                .frame(width: 32, height: 36)
                VStack(alignment: .leading, spacing: 0) {
                  VStack(alignment: .leading, spacing: 0) {
                    Text("Hello! I'm your Travel AI assistant. 🌏\nWhere would you like to go? Give me\ndates and a budget for a perfect plan!")
                      .font(Font.custom("Liberation Sans", size: 15))
                      .lineSpacing(20.63)
                      .foregroundColor(.black)
                  }
                  .padding(
                    EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 19.44)
                  )
                  .frame(maxWidth: 284.80)
                  .background(Color(red: 0.95, green: 0.95, blue: 0.97))
                  .cornerRadius(20)
                }
                .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 0))
                .frame(maxWidth: 292.80)
              }
              HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                  Text("Jeju Island, 2 Days")
                    .font(Font.custom("Liberation Sans", size: 15))
                    .lineSpacing(18.75)
                    .foregroundColor(.white)
                }
                .padding(
                  EdgeInsets(top: 11, leading: 16, bottom: 12.75, trailing: 16)
                )
                .frame(maxWidth: 284.80)
                .background(Color(red: 0, green: 0.48, blue: 1))
                .cornerRadius(20)
                .shadow(
                  color: Color(red: 0, green: 0, blue: 0, opacity: 0.05), radius: 2, y: 1
                )
              }
              HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                  HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 0) {

                    }
                  }
                  .frame(width: 32, height: 32)
                  .background(Color(red: 0, green: 0.48, blue: 1))
                  .cornerRadius(9999)
                }
                .padding(EdgeInsets(top: 4, leading: 0, bottom: 0, trailing: 0))
                .frame(width: 32, height: 36)
                VStack(alignment: .leading, spacing: 0) {
                  VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 0) {
                      Text("I've created a plan for your Jeju trip! ✈️\nCheck the route first.")
                        .font(Font.custom("Liberation Sans", size: 15))
                        .lineSpacing(20.63)
                        .foregroundColor(.black)
                    }
                    .padding(
                      EdgeInsets(top: 10.81, leading: 16, bottom: 12.44, trailing: 16)
                    )
                    .background(Color(red: 0.95, green: 0.95, blue: 0.97))
                    .cornerRadius(20)
                    VStack(alignment: .leading, spacing: 0) {
                      VStack(alignment: .leading, spacing: 24) {
                        HStack(spacing: 89.92) {
                          HStack(spacing: -0) {
                            VStack(alignment: .leading, spacing: 0) {

                            }
                            VStack(alignment: .leading, spacing: 0) {
                              Text("Jeju Route")
                                .font(Font.custom("Liberation Sans", size: 12).weight(.bold))
                                .lineSpacing(16)
                                .foregroundColor(.black)
                            }
                            .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 0))
                          }
                          .padding(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                          .background(Color(red: 1, green: 1, blue: 1).opacity(0.80))
                          .cornerRadius(9999)
                          .shadow(
                            color: Color(red: 0, green: 0, blue: 0, opacity: 0.05), radius: 2, y: 1
                          )
                          HStack(spacing: 0) {
                            VStack(alignment: .leading, spacing: 0) {

                            }
                            VStack(alignment: .leading, spacing: 0) {
                              Text("2 Days")
                                .font(Font.custom("Liberation Sans", size: 12).weight(.bold))
                                .lineSpacing(16)
                                .foregroundColor(.black)
                            }
                            .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 0))
                          }
                          .padding(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                          .background(Color(red: 1, green: 1, blue: 1).opacity(0.80))
                          .cornerRadius(9999)
                          .shadow(
                            color: Color(red: 0, green: 0, blue: 0, opacity: 0.05), radius: 2, y: 1
                          )
                        }
                        ZStack() {
                          ZStack() {

                          }
                          .frame(width: 282, height: 96)
                          .offset(x: 0, y: 0)
                        }
                        .frame(height: 96)
                        VStack(alignment: .leading, spacing: 16) {
                          HStack(spacing: 120.98) {
                            HStack(spacing: 0) {
                              Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 12, height: 12)
                                .background(Color(red: 0.29, green: 0.87, blue: 0.50))
                                .cornerRadius(9999)
                              VStack(alignment: .leading, spacing: 0) {
                                Text("Jeju Int'l Airport")
                                  .font(Font.custom("Liberation Sans", size: 13).weight(.medium))
                                  .lineSpacing(19.50)
                                  .foregroundColor(.black)
                              }
                              .padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 0))
                            }
                            VStack(alignment: .leading, spacing: 0) {
                              Text("10:00")
                                .font(Font.custom("Liberation Sans", size: 13))
                                .lineSpacing(19.50)
                                .foregroundColor(Color(red: 0.61, green: 0.64, blue: 0.69))
                            }
                          }
                          HStack(spacing: 88.01) {
                            HStack(spacing: 0) {
                              Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 12, height: 12)
                                .background(Color(red: 0, green: 0.48, blue: 1))
                                .cornerRadius(9999)
                              VStack(alignment: .leading, spacing: 0) {
                                Text("Seongsan Ilchulbong")
                                  .font(Font.custom("Liberation Sans", size: 13).weight(.medium))
                                  .lineSpacing(19.50)
                                  .foregroundColor(.black)
                              }
                              .padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 0))
                            }
                            VStack(alignment: .leading, spacing: 0) {
                              Text("14:00")
                                .font(Font.custom("Liberation Sans", size: 13))
                                .lineSpacing(19.50)
                                .foregroundColor(Color(red: 0.61, green: 0.64, blue: 0.69))
                            }
                          }
                          HStack(spacing: 153.79) {
                            HStack(spacing: 0) {
                              Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 12, height: 12)
                                .background(Color(red: 0, green: 0.48, blue: 1))
                                .cornerRadius(9999)
                              VStack(alignment: .leading, spacing: 0) {
                                Text("Seopjikoji")
                                  .font(Font.custom("Liberation Sans", size: 13).weight(.medium))
                                  .lineSpacing(19.50)
                                  .foregroundColor(.black)
                              }
                              .padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 0))
                            }
                            VStack(alignment: .leading, spacing: 0) {
                              Text("17:00")
                                .font(Font.custom("Liberation Sans", size: 13))
                                .lineSpacing(19.50)
                                .foregroundColor(Color(red: 0.61, green: 0.64, blue: 0.69))
                            }
                          }
                          HStack(spacing: 118.39) {
                            HStack(spacing: 0) {
                              Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 12, height: 12)
                                .background(Color(red: 0.94, green: 0.27, blue: 0.27))
                                .cornerRadius(9999)
                              VStack(alignment: .leading, spacing: 0) {
                                Text("Seogwipo Hotel")
                                  .font(Font.custom("Liberation Sans", size: 13).weight(.medium))
                                  .lineSpacing(19.50)
                                  .foregroundColor(.black)
                              }
                              .padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 0))
                            }
                            VStack(alignment: .leading, spacing: 0) {
                              Text("19:00")
                                .font(Font.custom("Liberation Sans", size: 13))
                                .lineSpacing(19.50)
                                .foregroundColor(Color(red: 0.61, green: 0.64, blue: 0.69))
                            }
                          }
                        }
                        .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
                      }
                      .padding(16)
                      .background(Color(red: 0.90, green: 0.95, blue: 1))
                    }
                    .background(.white)
                    .cornerRadius(24)
                    .overlay(
                      RoundedRectangle(cornerRadius: 24)
                        .inset(by: 0.50)
                        .stroke(Color(red: 0.95, green: 0.96, blue: 0.96), lineWidth: 0.50)
                    )
                    .shadow(
                      color: Color(red: 0, green: 0, blue: 0, opacity: 0.05), radius: 2, y: 1
                    )
                  }
                }
                .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 0))
              }
              HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                  HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 0) {

                    }
                  }
                  .frame(width: 32, height: 32)
                  .background(Color(red: 0, green: 0.48, blue: 1))
                  .cornerRadius(9999)
                }
                .padding(EdgeInsets(top: 4, leading: 0, bottom: 0, trailing: 0))
                .frame(width: 32, height: 36)
                VStack(alignment: .leading, spacing: 0) {
                  VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 0) {
                      Text("Here is the detailed schedule optimized for\ncurrent conditions.")
                        .font(Font.custom("Liberation Sans", size: 15))
                        .lineSpacing(20.63)
                        .foregroundColor(.black)
                    }
                    .padding(
                      EdgeInsets(top: 10.81, leading: 16, bottom: 12.44, trailing: 16)
                    )
                    .background(Color(red: 0.95, green: 0.95, blue: 0.97))
                    .cornerRadius(20)
                    VStack(alignment: .leading, spacing: 0) {
                      VStack(alignment: .leading, spacing: 7.50) {
                        VStack(alignment: .leading, spacing: 0) {
                          Text("Jeju Trip")
                            .font(Font.custom("Liberation Sans", size: 18).weight(.bold))
                            .lineSpacing(28)
                            .foregroundColor(.white)
                        }
                        HStack(spacing: 0) {
                          HStack(spacing: 4) {
                            VStack(alignment: .leading, spacing: 0) {

                            }
                            Text("Dec 20 - Dec 21")
                              .font(Font.custom("Liberation Sans", size: 11))
                              .lineSpacing(16.50)
                              .foregroundColor(.white)
                          }
                          VStack(alignment: .leading, spacing: 0) {
                            HStack(spacing: 4) {
                              VStack(alignment: .leading, spacing: 0) {

                              }
                              Text("2 People")
                                .font(Font.custom("Liberation Sans", size: 11))
                                .lineSpacing(16.50)
                                .foregroundColor(.white)
                            }
                          }
                          .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0))
                          VStack(alignment: .leading, spacing: 0) {
                            HStack(spacing: 4) {
                              VStack(alignment: .leading, spacing: 0) {

                              }
                              Text("$500.00")
                                .font(Font.custom("Liberation Sans", size: 11))
                                .lineSpacing(16.50)
                                .foregroundColor(.white)
                            }
                          }
                          .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0))
                        }
                        .opacity(0.90)
                        HStack(alignment: .top, spacing: 0) {
                          HStack(spacing: 3.99) {
                            VStack(spacing: 0) {

                            }
                            Text("Share")
                              .font(Font.custom("Liberation Sans", size: 12).weight(.medium))
                              .lineSpacing(16)
                              .foregroundColor(.white)
                          }
                          .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                          .frame(width: 137)
                          .background(Color(red: 1, green: 1, blue: 1).opacity(0.20))
                          .cornerRadius(8)
                          VStack(alignment: .leading, spacing: 0) {
                            HStack(spacing: 4) {
                              VStack(spacing: 0) {

                              }
                              Text("Save")
                                .font(Font.custom("Liberation Sans", size: 12).weight(.medium))
                                .lineSpacing(16)
                                .foregroundColor(.white)
                            }
                            .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                            .background(Color(red: 1, green: 1, blue: 1).opacity(0.20))
                            .cornerRadius(8)
                          }
                          .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 0))
                          .frame(width: 145)
                        }
                        .padding(EdgeInsets(top: 4.50, leading: 0, bottom: 0, trailing: 0))
                      }
                      .padding(16)
                      .background(Color(red: 0, green: 0.48, blue: 1))
                      HStack(spacing: 173.95) {
                        HStack(spacing: 0) {
                          HStack(spacing: 0) {
                            Text("1")
                              .font(Font.custom("Liberation Sans", size: 14).weight(.bold))
                              .lineSpacing(20)
                              .foregroundColor(.white)
                          }
                          .frame(width: 32, height: 32)
                          .background(Color(red: 0, green: 0.48, blue: 1))
                          .cornerRadius(9999)
                          ZStack() {
                            VStack(alignment: .leading, spacing: 0) {
                              VStack(alignment: .leading, spacing: 0) {
                                Text("Day 1")
                                  .font(Font.custom("Liberation Sans", size: 15).weight(.bold))
                                  .lineSpacing(22.50)
                                  .foregroundColor(.black)
                              }
                              VStack(alignment: .leading, spacing: 0) {
                                Text("Dec 20")
                                  .font(Font.custom("Liberation Sans", size: 11))
                                  .lineSpacing(16.50)
                                  .foregroundColor(Color(red: 0.42, green: 0.45, blue: 0.50))
                              }
                            }
                            .offset(x: 6, y: -0.50)
                          }
                          .frame(width: 52.03, height: 39)
                        }
                        VStack(alignment: .leading, spacing: 0) {

                        }
                      }
                      .padding(16)
                      .background(Color(red: 0.98, green: 0.98, blue: 0.98).opacity(0.30))
                      .overlay(
                        Rectangle()
                          .inset(by: 0.50)
                          .stroke(Color(red: 0.98, green: 0.98, blue: 0.98), lineWidth: 0.50)
                      )
                      VStack(alignment: .leading, spacing: 24) {
                        HStack(alignment: .top, spacing: 0) {
                          Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 2, height: 55)
                            .background(Color(red: 0.90, green: 0.91, blue: 0.92))
                            .offset(x: -133, y: 18)
                          VStack(alignment: .leading, spacing: 0) {
                            HStack(spacing: 0) {
                              VStack(alignment: .leading, spacing: 0) {

                              }
                            }
                            .frame(width: 16, height: 16)
                            .background(.white)
                            .cornerRadius(9999)
                            .overlay(
                              RoundedRectangle(cornerRadius: 9999)
                                .inset(by: 1)
                                .stroke(Color(red: 0.38, green: 0.65, blue: 0.98), lineWidth: 1)
                            )
                          }
                          .padding(EdgeInsets(top: 4, leading: 16, bottom: 0, trailing: 0))
                          .frame(width: 32, height: 20)
                          VStack(alignment: .leading, spacing: 0) {
                            VStack(alignment: .leading, spacing: 4) {
                              HStack(spacing: 153.55) {
                                VStack(alignment: .leading, spacing: 0) {
                                  Text("10:00")
                                    .font(Font.custom("Liberation Sans", size: 13).weight(.bold))
                                    .lineSpacing(19.50)
                                    .foregroundColor(Color(red: 0, green: 0.48, blue: 1))
                                }
                                VStack(alignment: .leading, spacing: 0) {
                                  Text("1 hour")
                                    .font(Font.custom("Liberation Sans", size: 11))
                                    .lineSpacing(16.50)
                                    .foregroundColor(Color(red: 0.61, green: 0.64, blue: 0.69))
                                }
                                .padding(EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8))
                                .background(Color(red: 0.95, green: 0.96, blue: 0.96))
                                .cornerRadius(4)
                              }
                              VStack(alignment: .leading, spacing: 0) {
                                Text("Arrival & Car Pickup")
                                  .font(Font.custom("Liberation Sans", size: 14).weight(.bold))
                                  .lineSpacing(21)
                                  .foregroundColor(.black)
                              }
                              HStack(spacing: 4) {
                                VStack(alignment: .leading, spacing: 0) {

                                }
                                Text("Jeju Int'l Airport")
                                  .font(Font.custom("Liberation Sans", size: 11))
                                  .lineSpacing(16.50)
                                  .foregroundColor(Color(red: 0.42, green: 0.45, blue: 0.50))
                              }
                            }
                          }
                          .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0))
                        }
                        HStack(alignment: .top, spacing: 0) {
                          Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 2, height: 55)
                            .background(Color(red: 0.90, green: 0.91, blue: 0.92))
                            .offset(x: -133, y: 18)
                          VStack(alignment: .leading, spacing: 0) {
                            HStack(spacing: 0) {
                              VStack(alignment: .leading, spacing: 0) {

                              }
                            }
                            .frame(width: 16, height: 16)
                            .background(.white)
                            .cornerRadius(9999)
                            .overlay(
                              RoundedRectangle(cornerRadius: 9999)
                                .inset(by: 1)
                                .stroke(Color(red: 0.38, green: 0.65, blue: 0.98), lineWidth: 1)
                            )
                          }
                          .padding(EdgeInsets(top: 4, leading: 16, bottom: 0, trailing: 0))
                          .frame(width: 32, height: 20)
                          VStack(alignment: .leading, spacing: 0) {
                            VStack(alignment: .leading, spacing: 4) {
                              HStack(spacing: 153.55) {
                                VStack(alignment: .leading, spacing: 0) {
                                  Text("12:00")
                                    .font(Font.custom("Liberation Sans", size: 13).weight(.bold))
                                    .lineSpacing(19.50)
                                    .foregroundColor(Color(red: 0, green: 0.48, blue: 1))
                                }
                                VStack(alignment: .leading, spacing: 0) {
                                  Text("1 hour")
                                    .font(Font.custom("Liberation Sans", size: 11))
                                    .lineSpacing(16.50)
                                    .foregroundColor(Color(red: 0.61, green: 0.64, blue: 0.69))
                                }
                                .padding(EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8))
                                .background(Color(red: 0.95, green: 0.96, blue: 0.96))
                                .cornerRadius(4)
                              }
                              VStack(alignment: .leading, spacing: 0) {
                                Text("Lunch - Local Cuisine")
                                  .font(Font.custom("Liberation Sans", size: 14).weight(.bold))
                                  .lineSpacing(21)
                                  .foregroundColor(.black)
                              }
                              HStack(spacing: 4) {
                                VStack(alignment: .leading, spacing: 0) {

                                }
                                Text("Jeju City Area")
                                  .font(Font.custom("Liberation Sans", size: 11))
                                  .lineSpacing(16.50)
                                  .foregroundColor(Color(red: 0.42, green: 0.45, blue: 0.50))
                              }
                            }
                          }
                          .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0))
                        }
                        HStack(alignment: .top, spacing: 0) {
                          Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 2, height: 55)
                            .background(Color(red: 0.90, green: 0.91, blue: 0.92))
                            .offset(x: -133, y: 18)
                          VStack(alignment: .leading, spacing: 0) {
                            HStack(spacing: 0) {
                              VStack(alignment: .leading, spacing: 0) {

                              }
                            }
                            .frame(width: 16, height: 16)
                            .background(.white)
                            .cornerRadius(9999)
                            .overlay(
                              RoundedRectangle(cornerRadius: 9999)
                                .inset(by: 1)
                                .stroke(Color(red: 0.38, green: 0.65, blue: 0.98), lineWidth: 1)
                            )
                          }
                          .padding(EdgeInsets(top: 4, leading: 16, bottom: 0, trailing: 0))
                          .frame(width: 32, height: 20)
                          VStack(alignment: .leading, spacing: 0) {
                            VStack(alignment: .leading, spacing: 4) {
                              HStack(spacing: 148.05) {
                                VStack(alignment: .leading, spacing: 0) {
                                  Text("14:00")
                                    .font(Font.custom("Liberation Sans", size: 13).weight(.bold))
                                    .lineSpacing(19.50)
                                    .foregroundColor(Color(red: 0, green: 0.48, blue: 1))
                                }
                                VStack(alignment: .leading, spacing: 0) {
                                  Text("2 hours")
                                    .font(Font.custom("Liberation Sans", size: 11))
                                    .lineSpacing(16.50)
                                    .foregroundColor(Color(red: 0.61, green: 0.64, blue: 0.69))
                                }
                                .padding(EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8))
                                .background(Color(red: 0.95, green: 0.96, blue: 0.96))
                                .cornerRadius(4)
                              }
                              VStack(alignment: .leading, spacing: 0) {
                                Text("Seongsan Ilchulbong Trekking")
                                  .font(Font.custom("Liberation Sans", size: 14).weight(.bold))
                                  .lineSpacing(21)
                                  .foregroundColor(.black)
                              }
                              HStack(spacing: 4) {
                                VStack(alignment: .leading, spacing: 0) {

                                }
                                Text("Seongsan")
                                  .font(Font.custom("Liberation Sans", size: 11))
                                  .lineSpacing(16.50)
                                  .foregroundColor(Color(red: 0.42, green: 0.45, blue: 0.50))
                              }
                            }
                          }
                          .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0))
                        }
                        HStack(alignment: .top, spacing: 0) {
                          VStack(alignment: .leading, spacing: 0) {
                            HStack(spacing: 0) {
                              VStack(alignment: .leading, spacing: 0) {

                              }
                            }
                            .frame(width: 16, height: 16)
                            .background(.white)
                            .cornerRadius(9999)
                            .overlay(
                              RoundedRectangle(cornerRadius: 9999)
                                .inset(by: 1)
                                .stroke(Color(red: 0.38, green: 0.65, blue: 0.98), lineWidth: 1)
                            )
                          }
                          .padding(EdgeInsets(top: 4, leading: 0, bottom: 0, trailing: 0))
                          .frame(width: 16, height: 20)
                          VStack(alignment: .leading, spacing: 0) {
                            VStack(alignment: .leading, spacing: 4) {
                              HStack(spacing: 164.05) {
                                VStack(alignment: .leading, spacing: 0) {
                                  Text("19:00")
                                    .font(Font.custom("Liberation Sans", size: 13).weight(.bold))
                                    .lineSpacing(19.50)
                                    .foregroundColor(Color(red: 0, green: 0.48, blue: 1))
                                }
                                VStack(alignment: .leading, spacing: 0) {
                                  Text("2 hours")
                                    .font(Font.custom("Liberation Sans", size: 11))
                                    .lineSpacing(16.50)
                                    .foregroundColor(Color(red: 0.61, green: 0.64, blue: 0.69))
                                }
                                .padding(EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8))
                                .background(Color(red: 0.95, green: 0.96, blue: 0.96))
                                .cornerRadius(4)
                              }
                              VStack(alignment: .leading, spacing: 0) {
                                Text("Dinner & Hotel Check-in")
                                  .font(Font.custom("Liberation Sans", size: 14).weight(.bold))
                                  .lineSpacing(21)
                                  .foregroundColor(.black)
                              }
                              HStack(spacing: 4) {
                                VStack(alignment: .leading, spacing: 0) {

                                }
                                Text("Seogwipo")
                                  .font(Font.custom("Liberation Sans", size: 11))
                                  .lineSpacing(16.50)
                                  .foregroundColor(Color(red: 0.42, green: 0.45, blue: 0.50))
                              }
                            }
                          }
                          .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0))
                        }
                      }
                      .padding(16)
                      HStack(spacing: 173.95) {
                        HStack(spacing: 0) {
                          HStack(spacing: 0) {
                            Text("2")
                              .font(Font.custom("Liberation Sans", size: 14).weight(.bold))
                              .lineSpacing(20)
                              .foregroundColor(Color(red: 0.29, green: 0.33, blue: 0.39))
                          }
                          .frame(width: 32, height: 32)
                          .background(Color(red: 0.90, green: 0.91, blue: 0.92))
                          .cornerRadius(9999)
                          ZStack() {
                            VStack(alignment: .leading, spacing: 0) {
                              VStack(alignment: .leading, spacing: 0) {
                                Text("Day 2")
                                  .font(Font.custom("Liberation Sans", size: 15).weight(.bold))
                                  .lineSpacing(22.50)
                                  .foregroundColor(.black)
                              }
                              VStack(alignment: .leading, spacing: 0) {
                                Text("Dec 21")
                                  .font(Font.custom("Liberation Sans", size: 11))
                                  .lineSpacing(16.50)
                                  .foregroundColor(Color(red: 0.42, green: 0.45, blue: 0.50))
                              }
                            }
                            .offset(x: 6, y: -0.50)
                          }
                          .frame(width: 52.03, height: 39)
                        }
                        .opacity(0.60)
                        VStack(alignment: .leading, spacing: 0) {

                        }
                      }
                      .padding(16)
                      .overlay(
                        Rectangle()
                          .inset(by: 0.50)
                          .stroke(Color(red: 0.95, green: 0.96, blue: 0.96), lineWidth: 0.50)
                      )
                      HStack(alignment: .top, spacing: 160.38) {
                        VStack(alignment: .leading, spacing: 0) {
                          Text("2 Day Itinerary")
                            .font(Font.custom("Liberation Sans", size: 11))
                            .lineSpacing(16.50)
                            .foregroundColor(Color(red: 0.61, green: 0.64, blue: 0.69))
                        }
                        VStack(alignment: .leading, spacing: 0) {
                          Text("10 Activities")
                            .font(Font.custom("Liberation Sans", size: 11))
                            .lineSpacing(16.50)
                            .foregroundColor(Color(red: 0.61, green: 0.64, blue: 0.69))
                        }
                      }
                      .padding(12)
                      .background(Color(red: 0.98, green: 0.98, blue: 0.98))
                    }
                    .background(.white)
                    .cornerRadius(24)
                    .overlay(
                      RoundedRectangle(cornerRadius: 24)
                        .inset(by: 0.50)
                        .stroke(Color(red: 0.95, green: 0.96, blue: 0.96), lineWidth: 0.50)
                    )
                    .shadow(
                      color: Color(red: 0, green: 0, blue: 0, opacity: 0.05), radius: 2, y: 1
                    )
                  }
                }
                .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 0))
              }
              HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                  HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 0) {

                    }
                  }
                  .frame(width: 32, height: 32)
                  .background(Color(red: 0, green: 0.48, blue: 1))
                  .cornerRadius(9999)
                }
                .padding(EdgeInsets(top: 4, leading: 0, bottom: 0, trailing: 0))
                .frame(width: 32, height: 36)
                VStack(alignment: .leading, spacing: 0) {
                  VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 0) {
                      Text("Would you like to book flights and hotels\ntoo? I've found the best options! ✈️🏨")
                        .font(Font.custom("Liberation Sans", size: 15))
                        .lineSpacing(20.63)
                        .foregroundColor(.black)
                    }
                    .padding(
                      EdgeInsets(top: 10.81, leading: 16, bottom: 12.44, trailing: 16)
                    )
                    .background(Color(red: 0.95, green: 0.95, blue: 0.97))
                    .cornerRadius(20)
                    VStack(alignment: .leading, spacing: 0) {
                      VStack(alignment: .leading, spacing: 0) {
                        Rectangle()
                          .foregroundColor(.clear)
                          .background(Color(red: 0.50, green: 0.23, blue: 0.27).opacity(0.50))
                        HStack(spacing: 0) {
                          VStack(alignment: .leading, spacing: 0) {

                          }
                        }
                        .frame(width: 32, height: 32)
                        .background(Color(red: 1, green: 1, blue: 1).opacity(0.20))
                        .cornerRadius(9999)
                        .overlay(
                          RoundedRectangle(cornerRadius: 9999)
                            .inset(by: 0.50)
                            .stroke(
                              Color(red: 1, green: 1, blue: 1).opacity(0.40), lineWidth: 0.50
                            )
                        )
                        .offset(x: -129, y: -36)
                        HStack(spacing: 0) {
                          VStack(alignment: .leading, spacing: 0) {

                          }
                          .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 4))
                          VStack(alignment: .leading, spacing: 0) {
                            Text("4.8 (342)")
                              .font(Font.custom("Liberation Sans", size: 10).weight(.bold))
                              .lineSpacing(15)
                              .foregroundColor(.black)
                          }
                        }
                        .padding(EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8))
                        .background(Color(red: 1, green: 1, blue: 1).opacity(0.80))
                        .cornerRadius(9999)
                        .offset(x: 109.15, y: -42.50)
                        .shadow(
                          color: Color(red: 0, green: 0, blue: 0, opacity: 0.05), radius: 2, y: 1
                        )
                      }
                      .frame(height: 128)
                      VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 0) {
                          HStack(spacing: 0) {
                            VStack(alignment: .leading, spacing: 0) {

                            }
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 4))
                            Text("Seoul (Gimpo)")
                              .font(Font.custom("Liberation Sans", size: 14).weight(.bold))
                              .lineSpacing(21)
                              .foregroundColor(.black)
                            VStack(alignment: .leading, spacing: 0) {

                            }
                            .padding(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4))
                            Text("Jeju")
                              .font(Font.custom("Liberation Sans", size: 14).weight(.bold))
                              .lineSpacing(21)
                              .foregroundColor(.black)
                            VStack(alignment: .leading, spacing: 0) {

                            }
                            .padding(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 0))
                          }
                        }
                        VStack(alignment: .leading, spacing: 0) {
                          Text("Korean Air • Non-stop 1h 10m")
                            .font(Font.custom("Liberation Sans", size: 11))
                            .lineSpacing(16.50)
                            .foregroundColor(Color(red: 0.42, green: 0.45, blue: 0.50))
                        }
                        HStack(alignment: .bottom, spacing: 105.36) {
                          VStack(alignment: .leading, spacing: 0) {
                            VStack(alignment: .leading, spacing: 0) {
                              Text("Total Price")
                                .font(Font.custom("Liberation Sans", size: 10))
                                .lineSpacing(15)
                                .foregroundColor(Color(red: 0.61, green: 0.64, blue: 0.69))
                            }
                            VStack(alignment: .leading, spacing: 0) {
                              Text("$198.00")
                                .font(Font.custom("Liberation Sans", size: 18).weight(.bold))
                                .lineSpacing(28)
                                .foregroundColor(Color(red: 0, green: 0.48, blue: 1))
                            }
                          }
                          VStack(spacing: 0) {
                            Text("Book Now")
                              .font(Font.custom("Liberation Sans", size: 13).weight(.bold))
                              .lineSpacing(19.50)
                              .foregroundColor(.white)
                          }
                          .padding(EdgeInsets(top: 10, leading: 24, bottom: 10, trailing: 24))
                          .background(Color(red: 0, green: 0.48, blue: 1))
                          .cornerRadius(12)
                        }
                        .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
                        HStack(alignment: .top, spacing: 0) {
                          Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 6, height: 6)
                            .background(Color(red: 0, green: 0.48, blue: 1))
                            .cornerRadius(9999)
                          VStack(alignment: .leading, spacing: 0) {
                            Rectangle()
                              .foregroundColor(.clear)
                              .frame(width: 6, height: 6)
                              .background(Color(red: 0.90, green: 0.91, blue: 0.92))
                              .cornerRadius(9999)
                          }
                          .padding(EdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 0))
                          .frame(width: 12, height: 6)
                          VStack(alignment: .leading, spacing: 0) {
                            Rectangle()
                              .foregroundColor(.clear)
                              .frame(width: 6, height: 6)
                              .background(Color(red: 0.90, green: 0.91, blue: 0.92))
                              .cornerRadius(9999)
                          }
                          .padding(EdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 0))
                          .frame(width: 12, height: 6)
                        }
                        .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
                      }
                      .padding(16)
                    }
                    .background(.white)
                    .cornerRadius(24)
                    .overlay(
                      RoundedRectangle(cornerRadius: 24)
                        .inset(by: 0.50)
                        .stroke(Color(red: 0.95, green: 0.96, blue: 0.96), lineWidth: 0.50)
                    )
                    .shadow(
                      color: Color(red: 0, green: 0, blue: 0, opacity: 0.05), radius: 2, y: 1
                    )
                  }
                }
                .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 0))
              }
              HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                  HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 0) {

                    }
                  }
                  .frame(width: 32, height: 32)
                  .background(Color(red: 0, green: 0.48, blue: 1))
                  .cornerRadius(9999)
                }
                .padding(EdgeInsets(top: 4, leading: 0, bottom: 0, trailing: 0))
                .frame(width: 32, height: 36)
                VStack(alignment: .leading, spacing: 0) {
                  VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 0) {
                      Text("Compare these two popular hotels!\nChoose the option that fits you best.")
                        .font(Font.custom("Liberation Sans", size: 15))
                        .lineSpacing(20.63)
                        .foregroundColor(.black)
                    }
                    .padding(
                      EdgeInsets(top: 10.81, leading: 16, bottom: 12.44, trailing: 16)
                    )
                    .background(Color(red: 0.95, green: 0.95, blue: 0.97))
                    .cornerRadius(20)
                    VStack(alignment: .leading, spacing: 0) {
                      VStack(alignment: .leading, spacing: 0) {
                        VStack(alignment: .leading, spacing: 0) {
                          Text("Option Comparison")
                            .font(Font.custom("Liberation Sans", size: 12).weight(.bold))
                            .lineSpacing(16)
                            .foregroundColor(.white)
                        }
                        VStack(alignment: .leading, spacing: 0) {
                          Text("Compare two options side by side")
                            .font(Font.custom("Liberation Sans", size: 10))
                            .lineSpacing(15)
                            .foregroundColor(.white)
                        }
                        .opacity(0.80)
                      }
                      .padding(12)
                      .background(Color(red: 0, green: 0.48, blue: 1))
                      VStack(alignment: .top, spacing: 0) {
                        VStack(alignment: .leading, spacing: 7) {
                          VStack(alignment: .leading, spacing: 0) {
                            Rectangle()
                              .foregroundColor(.clear)
                              .background(Color(red: 0.50, green: 0.23, blue: 0.27).opacity(0.50))
                            HStack(spacing: -0) {
                              VStack(alignment: .leading, spacing: 0) {

                              }
                              .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 2))
                              VStack(alignment: .leading, spacing: 0) {
                                Text("4.5")
                                  .font(Font.custom("Liberation Sans", size: 8).weight(.bold))
                                  .lineSpacing(12)
                                  .foregroundColor(.black)
                              }
                            }
                            .padding(EdgeInsets(top: 2, leading: 6, bottom: 2, trailing: 6))
                            .background(Color(red: 1, green: 1, blue: 1).opacity(0.80))
                            .cornerRadius(8)
                            .offset(x: 46.77, y: -34)
                          }
                          .frame(height: 96)
                          .cornerRadius(12)
                          VStack(alignment: .leading, spacing: 0) {
                            Text("Ramada Plaza Jeju")
                              .font(Font.custom("Liberation Sans", size: 11).weight(.bold))
                              .lineSpacing(13.75)
                              .foregroundColor(.black)
                          }
                          .frame(height: 33)
                          VStack(alignment: .leading, spacing: 0) {
                            Text("$280,000")
                              .font(Font.custom("Liberation Sans", size: 13).weight(.bold))
                              .lineSpacing(19.50)
                              .foregroundColor(Color(red: 0, green: 0.48, blue: 1))
                          }
                          .padding(EdgeInsets(top: 1, leading: 0, bottom: 0, trailing: 0))
                        }
                        VStack(alignment: .leading, spacing: 7) {
                          VStack(alignment: .leading, spacing: 0) {
                            Rectangle()
                              .foregroundColor(.clear)
                              .background(Color(red: 0.50, green: 0.23, blue: 0.27).opacity(0.50))
                            HStack(spacing: -0) {
                              VStack(alignment: .leading, spacing: 0) {

                              }
                              .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 2))
                              VStack(alignment: .leading, spacing: 0) {
                                Text("4.9")
                                  .font(Font.custom("Liberation Sans", size: 8).weight(.bold))
                                  .lineSpacing(12)
                                  .foregroundColor(.black)
                              }
                            }
                            .padding(EdgeInsets(top: 2, leading: 6, bottom: 2, trailing: 6))
                            .background(Color(red: 1, green: 1, blue: 1).opacity(0.80))
                            .cornerRadius(8)
                            .offset(x: 46.77, y: -34)
                          }
                          .frame(height: 96)
                          .cornerRadius(12)
                          VStack(alignment: .leading, spacing: 0) {
                            Text("The Shilla Jeju")
                              .font(Font.custom("Liberation Sans", size: 11).weight(.bold))
                              .lineSpacing(13.75)
                              .foregroundColor(.black)
                          }
                          .frame(height: 33)
                          VStack(alignment: .leading, spacing: 0) {
                            Text("$450,000")
                              .font(Font.custom("Liberation Sans", size: 13).weight(.bold))
                              .lineSpacing(19.50)
                              .foregroundColor(Color(red: 0, green: 0.48, blue: 1))
                          }
                          .padding(EdgeInsets(top: 1, leading: 0, bottom: 0, trailing: 0))
                        }
                      }
                      .padding(12)
                      VStack(alignment: .leading, spacing: 0) {
                        VStack(alignment: .leading, spacing: 8) {
                          VStack(spacing: 0) {
                            Text("Swimming Pool")
                              .font(Font.custom("Liberation Sans", size: 9))
                              .lineSpacing(13.50)
                              .foregroundColor(Color(red: 0.61, green: 0.64, blue: 0.69))
                          }
                          VStack(alignment: .top, spacing: 0) {
                            HStack(alignment: .top, spacing: 0) {
                              VStack(alignment: .leading, spacing: 0) {

                              }
                            }
                            .frame(height: 18)
                            HStack(alignment: .top, spacing: 0) {
                              VStack(alignment: .leading, spacing: 0) {

                              }
                            }
                            .frame(height: 18)
                          }
                        }
                        .padding(EdgeInsets(top: 11, leading: 0, bottom: 12, trailing: 0))
                        .overlay(
                          Rectangle()
                            .inset(by: 0.50)
                            .stroke(Color(red: 0.95, green: 0.96, blue: 0.96), lineWidth: 0.50)
                        )
                        VStack(alignment: .leading, spacing: 8) {
                          VStack(spacing: 0) {
                            Text("Breakfast Included")
                              .font(Font.custom("Liberation Sans", size: 9))
                              .lineSpacing(13.50)
                              .foregroundColor(Color(red: 0.61, green: 0.64, blue: 0.69))
                          }
                          VStack(alignment: .top, spacing: 0) {
                            HStack(alignment: .top, spacing: 0) {
                              VStack(alignment: .leading, spacing: 0) {

                              }
                            }
                            .frame(height: 18)
                            HStack(alignment: .top, spacing: 0) {
                              VStack(alignment: .leading, spacing: 0) {

                              }
                            }
                            .frame(height: 18)
                          }
                        }
                        .padding(EdgeInsets(top: 11, leading: 0, bottom: 12, trailing: 0))
                        .overlay(
                          Rectangle()
                            .inset(by: 0.50)
                            .stroke(Color(red: 0.95, green: 0.96, blue: 0.96), lineWidth: 0.50)
                        )
                        VStack(alignment: .leading, spacing: 8) {
                          VStack(spacing: 0) {
                            Text("Free WiFi")
                              .font(Font.custom("Liberation Sans", size: 9))
                              .lineSpacing(13.50)
                              .foregroundColor(Color(red: 0.61, green: 0.64, blue: 0.69))
                          }
                          VStack(alignment: .top, spacing: 0) {
                            HStack(alignment: .top, spacing: 0) {
                              VStack(alignment: .leading, spacing: 0) {

                              }
                            }
                            .frame(height: 18)
                            HStack(alignment: .top, spacing: 0) {
                              VStack(alignment: .leading, spacing: 0) {

                              }
                            }
                            .frame(height: 18)
                          }
                        }
                        .padding(EdgeInsets(top: 11, leading: 0, bottom: 12, trailing: 0))
                        .overlay(
                          Rectangle()
                            .inset(by: 0.50)
                            .stroke(Color(red: 0.95, green: 0.96, blue: 0.96), lineWidth: 0.50)
                        )
                        VStack(alignment: .leading, spacing: 8) {
                          VStack(spacing: 0) {
                            Text("Beach Access")
                              .font(Font.custom("Liberation Sans", size: 9))
                              .lineSpacing(13.50)
                              .foregroundColor(Color(red: 0.61, green: 0.64, blue: 0.69))
                          }
                          VStack(alignment: .top, spacing: 0) {
                            HStack(alignment: .top, spacing: 0) {
                              Text("5 min walk")
                                .font(Font.custom("Liberation Sans", size: 10).weight(.medium))
                                .lineSpacing(15)
                                .foregroundColor(.black)
                            }
                            .frame(height: 15)
                            HStack(alignment: .top, spacing: 0) {
                              Text("Beachfront")
                                .font(Font.custom("Liberation Sans", size: 10).weight(.medium))
                                .lineSpacing(15)
                                .foregroundColor(.black)
                            }
                            .frame(height: 15)
                          }
                        }
                        .padding(EdgeInsets(top: 11, leading: 0, bottom: 12, trailing: 0))
                        .overlay(
                          Rectangle()
                            .inset(by: 0.50)
                            .stroke(Color(red: 0.95, green: 0.96, blue: 0.96), lineWidth: 0.50)
                        )
                        VStack(alignment: .leading, spacing: 8) {
                          VStack(spacing: 0) {
                            Text("Free Parking")
                              .font(Font.custom("Liberation Sans", size: 9))
                              .lineSpacing(13.50)
                              .foregroundColor(Color(red: 0.61, green: 0.64, blue: 0.69))
                          }
                          VStack(alignment: .top, spacing: 0) {
                            HStack(alignment: .top, spacing: 0) {
                              VStack(alignment: .leading, spacing: 0) {

                              }
                            }
                            .frame(height: 18)
                            HStack(alignment: .top, spacing: 0) {
                              VStack(alignment: .leading, spacing: 0) {

                              }
                            }
                            .frame(height: 18)
                          }
                        }
                        .padding(EdgeInsets(top: 11, leading: 0, bottom: 12, trailing: 0))
                        .overlay(
                          Rectangle()
                            .inset(by: 0.50)
                            .stroke(Color(red: 0.95, green: 0.96, blue: 0.96), lineWidth: 0.50)
                        )
                      }
                      .background(Color(red: 0.98, green: 0.98, blue: 0.98).opacity(0.50))
                      VStack(alignment: .top, spacing: 0) {
                        VStack(spacing: 0) {
                          Text("Select")
                            .font(Font.custom("Liberation Sans", size: 12).weight(.bold))
                            .lineSpacing(18)
                            .foregroundColor(.white)
                        }
                        .padding(
                          EdgeInsets(top: 8, leading: 51.81, bottom: 8, trailing: 51.83)
                        )
                        .background(Color(red: 0, green: 0.48, blue: 1))
                        .cornerRadius(12)
                        VStack(spacing: 0) {
                          Text("Select")
                            .font(Font.custom("Liberation Sans", size: 12).weight(.bold))
                            .lineSpacing(18)
                            .foregroundColor(.white)
                        }
                        .padding(
                          EdgeInsets(top: 8, leading: 51.81, bottom: 8, trailing: 51.83)
                        )
                        .background(Color(red: 0, green: 0.48, blue: 1))
                        .cornerRadius(12)
                      }
                      .padding(12)
                    }
                    .background(.white)
                    .cornerRadius(24)
                    .overlay(
                      RoundedRectangle(cornerRadius: 24)
                        .inset(by: 0.50)
                        .stroke(Color(red: 0.95, green: 0.96, blue: 0.96), lineWidth: 0.50)
                    )
                    .shadow(
                      color: Color(red: 0, green: 0, blue: 0, opacity: 0.05), radius: 2, y: 1
                    )
                  }
                }
                .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 0))
              }
            }
            .padding(EdgeInsets(top: 16, leading: 16, bottom: 128, trailing: 16))
            .frame(width: 388, height: 2519.13)
            .offset(x: 0, y: 862.57)
            VStack(alignment: .leading, spacing: 0) {
              ZStack() {
                HStack(spacing: 0) {
                  VStack(spacing: 0) {

                  }
                }
                .frame(width: 40)
                .offset(x: -158, y: 0)
                VStack(alignment: .leading, spacing: 0) {
                  Text("Travel AI")
                    .font(Font.custom("Liberation Sans", size: 17).weight(.semibold))
                    .lineSpacing(25.50)
                    .foregroundColor(.black)
                }
                .offset(x: -0.01, y: 0)
                HStack(alignment: .top, spacing: 0) {
                  VStack(alignment: .leading, spacing: 0) {

                  }
                  VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: 0) {

                    }
                  }
                  .padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 0))
                }
                .frame(width: 56)
                .offset(x: 149.98, y: 0)
              }
              .frame(height: 44)
            }
            .frame(width: 388)
            .background(Color(red: 1, green: 1, blue: 1).opacity(0.90))
            .overlay(
              Rectangle()
                .inset(by: 0.50)
                .stroke(Color(red: 0.90, green: 0.91, blue: 0.92), lineWidth: 0.50)
            )
            .offset(x: 0, y: -419.50)
          }
          .frame(height: 884)
          .frame(maxWidth: 430)
          .background(.white)
          .overlay(
            Rectangle()
              .inset(by: 0.50)
              .stroke(Color(red: 0.95, green: 0.96, blue: 0.96), lineWidth: 0.50)
          )
    }

    private var inputBar: some View {
          VStack(alignment: .leading, spacing: 0) {
            ZStack() {
              VStack(spacing: 0) {
                HStack(alignment: .top, spacing: 0) {

                }
              }
              .offset(x: -170.84, y: -4.01)
              VStack(alignment: .leading, spacing: 0) {
                VStack(spacing: 0) {
                  HStack(alignment: .top, spacing: 0) {

                  }
                }
                .padding(8)
                .background(Color(red: 0, green: 0.48, blue: 1))
                .cornerRadius(9999)
              }
              .padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 0))
              .offset(x: 151.67, y: -7.34)
              VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                  VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: 0) {
                      Text("Enter destination and dates...")
                        .font(Font.custom("Liberation Sans", size: 16))
                        .foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.58))
                    }
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 1, trailing: 0))
                  }
                  .padding(EdgeInsets(top: 13, leading: 16, bottom: 13, trailing: 40))
                  .background(.white)
                  .cornerRadius(9999)
                  .overlay(
                    RoundedRectangle(cornerRadius: 9999)
                      .inset(by: 0.50)
                      .stroke(Color(red: 0.82, green: 0.84, blue: 0.86), lineWidth: 0.50)
                  )
                  VStack(alignment: .leading, spacing: 0) {

                  }
                  .offset(x: 117.16, y: -2.09)
                }
              }
              .padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 0))
              .frame(width: 281.98)
              .offset(x: -9.99, y: -4)
            }
            .frame(height: 54)
          }
          .padding(EdgeInsets(top: 12, leading: 0, bottom: 8, trailing: 0))
          .frame(width: 390)
          .frame(maxWidth: 430)
          .background(Color(red: 1, green: 1, blue: 1).opacity(0.80))
          .overlay(
            Rectangle()
              .inset(by: 0.50)
              .stroke(
                Color(red: 0, green: 0, blue: 0).opacity(0.10), lineWidth: 0.50
              )
          )
          .offset(x: 1, y: 404.50)
    }

}

#Preview {
    ContentView()
}
