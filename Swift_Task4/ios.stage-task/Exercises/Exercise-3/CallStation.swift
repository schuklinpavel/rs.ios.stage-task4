import Foundation

final class CallStation {
    var stationUsers: [User] = []
    var stationCalls: [Call] = []
    var stationCurrentCalls: [UUID: Call] = [:]
}

extension CallStation: Station {
    func getUserIndex(user: User) -> Int? {
        return stationUsers.firstIndex(of: user)
    }
    
    func users() -> [User] {
        return stationUsers
    }
    
    func add(user: User) {
        let index = getUserIndex(user: user)
        if (index == nil) {
            stationUsers.append(user)
        }
    }
    
    func remove(user: User) {
        let index = getUserIndex(user: user)
        if (index != nil) {
            stationUsers.remove(at: index!)
        }
    }
    
    func execute(action: CallAction) -> CallID? {
        let callId = CallID()
        switch action {
        case let .start(from: user1, to: user2):
            guard getUserIndex(user: user1) != nil else {
                return nil
            }
            
            if (stationCurrentCalls[user2.id] != nil) {
                let newCall = Call(id: callId, incomingUser: user1, outgoingUser: user2, status: .ended(reason: .userBusy))
                stationCalls.append(newCall)
                return callId
            }
            
            if (getUserIndex(user: user2) == nil) {
                let newCall = Call(id: callId, incomingUser: user1, outgoingUser: user2, status: .ended(reason: .error))
                stationCalls.append(newCall)
                return callId
            }
            
            let call = Call(id: callId, incomingUser: user1, outgoingUser: user2, status: .calling)
            stationCalls.append(call)
            stationCurrentCalls[user1.id] = call
            stationCurrentCalls[user2.id] = call
            return callId
            
        case let .answer(from: userAnswer):
            guard (stationCurrentCalls[userAnswer.id] != nil) else {
                return nil
            }
            
            let index = stationCalls.firstIndex(where: { $0.outgoingUser.id == userAnswer.id})
            if (index != nil) {
                if (getUserIndex(user: userAnswer) != nil) {
                    let call = stationCalls[index!]
                    let newCall = Call(id: call.id, incomingUser: call.incomingUser, outgoingUser: userAnswer, status: .talk)
                    stationCalls[index!] = newCall
                    stationCurrentCalls[call.incomingUser.id] = newCall
                    stationCurrentCalls[call.outgoingUser.id] = newCall
                    return call.id
                }
                let call = stationCalls[index!]
                let newCall = Call(id: call.id, incomingUser: call.incomingUser, outgoingUser: userAnswer, status: .ended(reason: .error))
                stationCalls[index!] = newCall
                stationCurrentCalls[call.incomingUser.id] = nil
                stationCurrentCalls[call.outgoingUser.id] = nil
                return nil
            }
            
            
            
        case let .end(from: userEnd):
            let index = stationCalls.firstIndex(where: { $0.outgoingUser.id == userEnd.id || $0.incomingUser.id == userEnd.id})
            if (index != nil) {
                let call = stationCalls[index!]
                let isNoTalkStatus = currentCall(user: userEnd)?.status != .talk

                if (getUserIndex(user: userEnd) == nil) {
                    let newCall = Call(id: call.id, incomingUser: call.incomingUser, outgoingUser: call.outgoingUser, status: .ended(reason: .error))
                    stationCalls[index!] = newCall
                    stationCurrentCalls[call.incomingUser.id] = nil
                    stationCurrentCalls[call.outgoingUser.id] = nil
                    return call.id
                }
                
                if (isNoTalkStatus) {
                    let newCall = Call(id: call.id, incomingUser: call.incomingUser, outgoingUser: call.outgoingUser, status: .ended(reason: .cancel))
                    stationCalls[index!] = newCall
                    stationCurrentCalls[call.incomingUser.id] = nil
                    stationCurrentCalls[call.outgoingUser.id] = nil
                    return call.id
                }
                
                let newCall = Call(id: call.id, incomingUser: call.incomingUser, outgoingUser: call.outgoingUser, status: .ended(reason: .end))
                stationCalls[index!] = newCall
                stationCurrentCalls[call.incomingUser.id] = nil
                stationCurrentCalls[call.outgoingUser.id] = nil
                return call.id
            }
        }
        return nil
    }
    
    func calls() -> [Call] {
        return stationCalls
    }
    
    func calls(user: User) -> [Call] {
        return stationCalls.filter({ $0.incomingUser.id == user.id || $0.outgoingUser.id == user.id })
    }
    
    func call(id: CallID) -> Call? {
        let calls = stationCalls.filter({ $0.id == id })
        if ((calls.count) != 0) {
            return calls[0]
        }
        return nil
    }
    
    func currentCall(user: User) -> Call? {
        // let index = stationCurrentCalls.firstIndex(where: { $0.id == user.id })
        return stationCurrentCalls[user.id]
    }
}
