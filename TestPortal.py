import PortalConnection

def pause():
  input("Press Enter to continue...")
  print("")

if __name__ == "__main__":        
    c = PortalConnection.PortalConnection()
    
    # Write your tests here. Add/remove calls to pause() as desired. 
    
    print("Test 1:") # get info
    print(c.getInfo("3333333333"))
    pause()

    print("Test 2:") # test register to unlimited course (success)
    print(c.register("3333333333", "CCC111"))
    print(c.getInfo("3333333333"))
    pause()

    print("Test 3:") # test register to same course (fail)
    print(c.register("3333333333", "CCC111"))
    print(c.getInfo("3333333333"))
    pause()

    print("Test 4:") # test unregister twice from course (success, then fail)
    print(c.unregister("3333333333", "CCC111"))
    print(c.getInfo("3333333333"))
    print(c.unregister("3333333333", "CCC111"))
    pause()

    print("Test 5:") # test register student to course without prerequisites (fail)
    print(c.register("3333333333", "CCC444"))
    pause()

    print("Test 6:") # unregister student from limited course with at least two people waiting, the reregister (success)
    print(c.register("3333333333", "CCC222")) # s3 waiting

    print(c.unregister("2222222222", "CCC222")) # check that s1 is now registered and s3 has waiting position 1
    pause()
    print(c.register("4444444444", "CCC222")) # check that s2 has waiting position 2
    pause()

    print("Test 7:") # unregister then register student from restricted course to check that it keeps its last position
    print(c.unregister("4444444444", "CCC222"))
    print(c.register("4444444444", "CCC222")) # check that s2 still has waiting pos 2 
    pause()

    print("Test 8:") # unregister student from overful course to see that the waiting list is the same
    # manually register student s5 to course c2
    # check waiting list course c2
    pause()
    print(c.unregister("5555555555", "CCC222")) # check waiting list same

    #print(c.unregister("2222222222", "CCC333"))
    #print(c.getInfo("3333333333"))
    #pause()
    
    #print("Test 2:")
    #print(c.register("2222222222", "CCC333")); 
    #print(c.getInfo("2222222222"))
    #pause()    