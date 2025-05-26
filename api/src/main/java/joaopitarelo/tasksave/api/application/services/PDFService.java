package joaopitarelo.tasksave.api.application.services;

import com.openhtmltopdf.pdfboxout.PdfRendererBuilder;
import com.openhtmltopdf.svgsupport.BatikSVGDrawer;
import joaopitarelo.tasksave.api.domain.subtask.Subtask;
import joaopitarelo.tasksave.api.domain.task.Task;
import joaopitarelo.tasksave.api.infraestruture.exceptions.GenerationPdfException;
import joaopitarelo.tasksave.api.interfaces.dtos.task.OutputTask;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.thymeleaf.TemplateEngine;
import org.thymeleaf.context.Context;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.List;

@Service
public class PDFService {

    @Autowired
    private TemplateEngine templateEngine;

    public byte[] generatePDF(String userLogin, List<Task> tasks) {
        try {
            // Carregando as variáveis para serem usadas no HTML
            Context context = new Context();
            context.setVariable("tasks", tasks.stream().map(OutputTask::new));
            context.setVariable("userLogin", userLogin);

            // Processando o html e inserindo as variáveis (tasks)
            String html = templateEngine.process("tasks-to-pdf-template", context);

            ByteArrayOutputStream baos = new ByteArrayOutputStream();

            // Construtor do OpenHTMLtoPDF
            PdfRendererBuilder builder = new PdfRendererBuilder();
            builder.useFastMode();
            builder.withHtmlContent(html, null);
            builder.useSVGDrawer(new BatikSVGDrawer()); // necessário para carregar SVGs
            builder.toStream(baos);
            builder.run();

            return baos.toByteArray();
        } catch (IOException e) {
            throw new GenerationPdfException("erro generating PDF", e);
        }
    }
}
