/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package Business.Organization;

import Business.Organization.Organization.Type;
import java.util.ArrayList;

public class OrganizationDirectory {
    
    private ArrayList<Organization> organizationList;

    public OrganizationDirectory() {
        organizationList = new ArrayList();
    }

    public ArrayList<Organization> getOrganizationList() {
        return organizationList;
    }
    
    public Organization createOrganization(Type type){
        Organization organization = null;
        if (type.getValue().equals(Type.Doctors.getValue())){
            organization = new DoctorsOrganization();
            organizationList.add(organization);
        }
        else if (type.getValue().equals(Type.Team.getValue())){
            organization = new TeamOrganization();
            organizationList.add(organization);
        }
        return organization;
    }
}