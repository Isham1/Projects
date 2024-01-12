/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package Business.Organization;

import Business.Role.PlayerRole;
import Business.Role.Role;
import static Business.Role.Role.RoleType.PlayerRole;
import java.util.ArrayList;


public class TeamOrganization extends Organization {
    
    public TeamOrganization()
    {
        super(Organization.Type.Team.getValue());
    }
    
      @Override
    public ArrayList<Role> getSupportedRole() {
        ArrayList<Role> roles = new ArrayList<>();
        roles.add(new PlayerRole());
        return roles;
    }
    
}
