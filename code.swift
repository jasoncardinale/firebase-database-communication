if(isSharing || isUsing) {
            refHandle = ref.child("users").observe(.childChanged, with: { (data) in
                let update : [String] = (data.value as? [String]) ?? ["","","","","","","","","","","","","","",""]
                if(update[9] == "t") {
                    //TODO: check if lat/long in mapView region so location can be displayed by circle render
                }
                if(self.connectionStatus != "u" && self.connectionStatus != "c") {
                    if(update[5] != uid) {
                        if(isUsing) {
                            if(update[2] == "s") {
                                if(self.isPoor) {
                                    let dist = haversineDistance(la1: self.centerLat, lo1: self.centerLong, la2: Double(update[0])!, lo2: Double(update[1])!)
                                    if(dist <= self.hotspotTriggerRange) {
                                        self.connectionStatus = "c"
                                        self.updateServer(lat: self.centerLat, long: self.centerLong, signal: self.signalStrength)
                                        let providerInfo = [update[0], update[1], update[2], update[3], update[4], update[5], "c", String(self.dataUsedInSession), update[8], update[9]]
                                        self.ref.child("users").child(update[5]).setValue(providerInfo)
                                        receivedLat = update[0]
                                        receivedLong = update[1]
                                        receivedSSID = update[3]
                                        receivedKey = update[4]
                                        receivedUID = update[5]
                                        //self.connectToProviderHotspot()
                                        self.attemptHotspotConnection(attemptSSID: receivedSSID, attemptKey: receivedKey)
                                    }
                                }
                            }
                        }
                        if(isSharing) {
                            if(update[2] == "p") {
                                if(self.isStrong) {
                                    let dist = haversineDistance(la1: self.centerLat, lo1: self.centerLong, la2: Double(update[0])!, lo2: Double(update[1])!)
                                    if(dist <= self.hotspotTriggerRange) {
                                        self.connectionStatus = "c"
                                        self.updateServer(lat: self.centerLat, long: self.centerLong, signal: self.signalStrength)
                                        let userInfo = [update[0], update[1], update[2], update[3], update[4], update[5], "c", String(self.dataUsedInSession), update[8], update[9], String(self.centerLat), String(self.centerLong), SSID, uniqueKey, uid]
                                        self.ref.child("users").child(update[5]).setValue(userInfo)
                                        self.userWantsToConnect()
                                    }
                                }
                            }
                        }
                    } else {
                        if(self.isStrong) {
                            if(update[6] == "c") {
                                self.connectionStatus = "c"
                                self.userWantsToConnect()
                            }
                            
                        }
                        if(self.isPoor) {
                            if(update[6] == "c") {
                                self.connectionStatus = "c"
                                receivedLat = update[10]
                                receivedLong = update[11]
                                receivedSSID = update[12]
                                receivedKey = update[13]
                                receivedUID = update[14]
                                self.attemptHotspotConnection(attemptSSID: receivedSSID, attemptKey: receivedKey)
                            }
                            if(update[6] == "u") {
                            }
                        }
                    }
                } else {
                    if(update[5] == uid) {
                        if(self.connectionStatus == "u") {
                            self.dataUsedInSession = Double(update[7])!
                            //dataUsed += self.dataUsedInSession
                            //defaults.set(dataUsed, forKey: "dataUsedShared")
                            
                            
                            //self.data_used_label.text = "\(self.dataSharedInSession.roundTo(places: 4)) GB"
                        }
                        if(update[6] == "p") {
                            self.connectionStatus = "p"
                            let connectedUser: [String] = [update[8], update[7]]
                            self.connectedUsers.append(connectedUser)
                            //self.updateServer(lat: self.centerLat, long: self.centerLong, signal: "x")
                            //dataShared = Double(update[7]) as! Double
                            //defaults.set(dataShared, forKey: "dataSavedShared")
                            //self.data_shared_label.text = "\(dataShared.roundTo(places: 4)) GB"
                            //let dataUsedInCurrentSession = Double(update[7])
                            //self.data_shared_label.text = "\(dataUsedInCurrentSession!.roundTo(places: 4)) GB"
                        }
                    } else {
                        if(self.connectionStatus == "u" && update[6] == "") {
                            NEHotspotConfigurationManager.shared.removeConfiguration(forSSID: update[3])
                        }
                    }
                }
            })
        }
