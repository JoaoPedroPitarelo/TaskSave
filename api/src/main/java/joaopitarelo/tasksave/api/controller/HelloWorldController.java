package joaopitarelo.tasksave.api.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/hello")
public class HelloWorldController {

    @GetMapping // Responde à /hello
    public String helloWorld() {
        return "<h1>Hello World! <br>Welcome to TaskSave!</h1>";
    }
}
