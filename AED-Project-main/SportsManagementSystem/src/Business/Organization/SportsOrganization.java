/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package Business.Organization;

import Business.Role.DataAnalystRole;
import Business.Role.PlayerRole;
import Business.Role.Role;
import Business.Role.SystemAdminRole;
import java.util.ArrayList;


public class SportsOrganization extends Organization {
    
    public SportsOrganization()
    {
        super(Organization.Type.Sports.getValue());
    }
    
      @Override
    public ArrayList<Role> getSupportedRole() {
        ArrayList<Role> roles = new ArrayList<>();
        roles.add(new DataAnalystRole());
        roles.add(new SystemAdminRole());
        return roles;
    }
    
}
