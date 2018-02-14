package gws;

import com.intuit.karate.junit4.Karate;
import cucumber.api.CucumberOptions;
import org.junit.runner.RunWith;


@RunWith(Karate.class)
@CucumberOptions(features = "classpath:gws/groupsSearch.feature")
public class GroupsRunner {

}