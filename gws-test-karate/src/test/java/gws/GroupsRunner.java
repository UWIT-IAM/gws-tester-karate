package gws;

import com.intuit.karate.junit4.Karate;
import cucumber.api.CucumberOptions;
import org.junit.runner.RunWith;


@RunWith(Karate.class)
//to run only a single feature
@CucumberOptions(features = "classpath:gws/subgroupCreatorManipulationTests.feature")
//@CucumberOptions(features = "classpath:gws/groupsAffiliates.feature")
public class GroupsRunner {

}