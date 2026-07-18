import Foundation

nonisolated enum MarkdownDocumentRenderer {
    static func render(_ markdown: String, appearance: MarkdownAppearance) -> String {
        let body = MarkdownParser(markdown: markdown).parse()
        return document(
            body: body,
            appearance: appearance,
            includesMermaid: body.contains("class=\"mermaid-source\"")
        )
    }

    static func renderError(
        title: String,
        message: String,
        appearance: MarkdownAppearance
    ) -> String {
        let body = """
        <div class="document-error">
          <div class="document-error-icon">!</div>
          <h2>\(InlineMarkdown.escapeHTML(title))</h2>
          <p>\(InlineMarkdown.escapeHTML(message))</p>
        </div>
        """
        return document(body: body, appearance: appearance, includesMermaid: false)
    }

    private static func document(
        body: String,
        appearance: MarkdownAppearance,
        includesMermaid: Bool = true
    ) -> String {
        let isDark = appearance == .dark
        let mermaidTheme = isDark ? "dark" : "neutral"
        let script = includesMermaid ? """
        <script>
          (() => {
            const diagrams = document.querySelectorAll(".mermaid-source");

            function showMermaidError(element) {
              element.textContent = "";
              element.classList.add("mermaid-error");
              const title = document.createElement("strong");
              title.textContent = "Mermaid 图表渲染失败";
              const detail = document.createElement("span");
              detail.textContent = "请检查图表语法。";
              element.append(title, detail);
            }

            async function renderDiagrams() {
              if (!window.mermaid) {
                diagrams.forEach(showMermaidError);
                return;
              }

              mermaid.initialize({
                startOnLoad: false,
                securityLevel: "strict",
                theme: "\(mermaidTheme)",
                fontFamily: "-apple-system, BlinkMacSystemFont, sans-serif"
              });

              for (let index = 0; index < diagrams.length; index++) {
                const element = diagrams[index];
                const source = element.textContent;
                try {
                  const result = await mermaid.render(`mermaid-${index}-${Date.now()}`, source);
                  element.innerHTML = result.svg;
                  element.classList.add("mermaid-rendered");
                  if (result.bindFunctions) result.bindFunctions(element);
                } catch (error) {
                  showMermaidError(element);
                }
              }
            }

            function loadMermaid() {
              if (window.mermaid) {
                renderDiagrams();
                return;
              }

              const loader = document.createElement("script");
              loader.src = "mermaid.min.js";
              loader.async = true;
              loader.addEventListener("load", renderDiagrams, { once: true });
              loader.addEventListener(
                "error",
                () => diagrams.forEach(showMermaidError),
                { once: true }
              );
              document.head.appendChild(loader);
            }

            requestAnimationFrame(() => setTimeout(loadMermaid, 0));
          })();
        </script>
        """ : ""

        return """
        <!doctype html>
        <html lang="zh-CN" data-theme="\(appearance.rawValue)">
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <meta http-equiv="Content-Security-Policy"
                content="default-src 'none'; script-src 'self' 'unsafe-inline'; style-src 'unsafe-inline'; img-src data:; font-src 'self' data:">
          <style>
            :root {
              color-scheme: light;
              --page: #ffffff;
              --text: #37352f;
              --heading: #2f2e2a;
              --muted: #73716b;
              --faint: #9b9993;
              --line: rgba(55, 53, 47, .16);
              --code: rgba(135, 131, 120, .15);
              --code-block: #f7f6f3;
              --link: #2b6f9f;
              --selection: rgba(46, 170, 220, .22);
            }

            html[data-theme="dark"] {
              color-scheme: dark;
              --page: #191919;
              --text: #d4d4d3;
              --heading: #efefee;
              --muted: #a5a5a3;
              --faint: #777775;
              --line: rgba(255, 255, 255, .14);
              --code: rgba(255, 255, 255, .10);
              --code-block: #242424;
              --link: #6ca8cf;
              --selection: rgba(46, 170, 220, .28);
            }

            * { box-sizing: border-box; }
            html, body { margin: 0; min-height: 100%; background: var(--page); }
            body {
              color: var(--text);
              font-family: -apple-system, BlinkMacSystemFont, "SF Pro Text", "Helvetica Neue", Arial, sans-serif;
              font-size: 16px;
              font-weight: 400;
              line-height: 1.7;
              overflow-wrap: break-word;
              overflow-anchor: none;
              -webkit-font-smoothing: antialiased;
            }
            ::selection { background: var(--selection); }
            main {
              width: min(820px, calc(100% - 96px));
              min-width: 0;
              margin: 0 auto;
              padding: 58px 0 96px;
            }
            h1, h2, h3, h4, h5, h6 {
              color: var(--heading);
              line-height: 1.25;
              letter-spacing: -.018em;
              margin: 1.55em 0 .55em;
            }
            h1 { font-size: 40px; font-weight: 700; margin-top: 0; }
            h2 { font-size: 30px; font-weight: 650; }
            h3 { font-size: 24px; font-weight: 600; }
            h4 { font-size: 20px; font-weight: 600; }
            h5 { font-size: 17px; font-weight: 600; }
            h6 { font-size: 16px; font-weight: 600; color: var(--muted); }
            p { margin: .55em 0 1em; }
            strong { font-weight: 650; color: var(--heading); }
            del { color: var(--muted); }
            a { color: var(--link); text-decoration: none; }
            a:hover { text-decoration: underline; }
            hr { height: 1px; border: 0; background: var(--line); margin: 2.2em 0; }
            blockquote {
              color: var(--muted);
              border-left: 3px solid var(--heading);
              margin: 1.2em 0;
              padding: .05em 0 .05em 1em;
            }
            blockquote > :first-child { margin-top: 0; }
            blockquote > :last-child { margin-bottom: 0; }
            ul, ol { margin: .55em 0 1em; padding-left: 1.6em; }
            li { margin: .18em 0; padding-left: .18em; }
            li > ul, li > ol { margin: .12em 0; }
            li.task { list-style: none; margin-left: -1.4em; }
            li.task input {
              width: 14px;
              height: 14px;
              margin: 0 .55em 0 0;
              vertical-align: -.08em;
              accent-color: #2383e2;
            }
            li.task.done { color: var(--muted); text-decoration: line-through; }
            code, pre {
              font-family: ui-monospace, "SFMono-Regular", SFMono-Regular, Menlo, Monaco, Consolas, monospace;
            }
            code {
              font-size: .88em;
              background: var(--code);
              border-radius: 4px;
              padding: .14em .34em;
            }
            pre {
              background: var(--code-block);
              border-radius: 6px;
              font-size: 13.5px;
              line-height: 1.6;
              margin: 1.25em 0;
              overflow-x: auto;
              padding: 16px 18px;
              tab-size: 4;
              white-space: pre;
            }
            pre code { font-size: inherit; background: transparent; padding: 0; }
            .table-scroll { margin: 1.3em 0; overflow-x: auto; }
            table { border-collapse: collapse; min-width: 100%; width: max-content; }
            th, td {
              border: 1px solid var(--line);
              padding: 8px 12px;
              text-align: left;
              vertical-align: top;
            }
            th { color: var(--heading); font-weight: 600; background: var(--code-block); }
            .mermaid-source {
              background: transparent;
              color: var(--text);
              display: block;
              margin: 28px auto;
              max-width: 100%;
              overflow-x: auto;
              text-align: center;
              white-space: pre;
            }
            .mermaid-rendered svg {
              display: block;
              height: auto;
              margin: 0 auto;
              max-width: 100%;
            }
            .mermaid-error {
              border-left: 3px solid #d44c47;
              color: var(--muted);
              padding: 8px 12px;
              text-align: left;
              white-space: normal;
            }
            .mermaid-error strong, .mermaid-error span { display: block; }
            .mermaid-error strong { color: var(--heading); }
            .document-error {
              color: var(--muted);
              margin: 18vh auto 0;
              max-width: 480px;
              text-align: center;
            }
            .document-error h2 { font-size: 22px; margin: 14px 0 4px; }
            .document-error p { margin-top: 4px; }
            .document-error-icon {
              border: 1px solid var(--line);
              border-radius: 50%;
              color: var(--muted);
              display: grid;
              font-weight: 600;
              height: 42px;
              margin: 0 auto;
              place-items: center;
              width: 42px;
            }
            @media (max-width: 680px) {
              main { width: calc(100% - 48px); padding-top: 40px; }
              h1 { font-size: 34px; }
              h2 { font-size: 27px; }
            }
          </style>
        </head>
        <body>
          <main>\(body)</main>
          \(script)
        </body>
        </html>
        """
    }
}

nonisolated private final class MarkdownParser {
    private static let maximumNestingDepth = 64

    private let lines: [String]
    private let nestingDepth: Int
    private var index = 0

    init(markdown: String, nestingDepth: Int = 0) {
        self.nestingDepth = nestingDepth
        lines = markdown
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
            .components(separatedBy: "\n")
    }

    func parse() -> String {
        var output: [String] = []

        while index < lines.count {
            let line = lines[index]

            if line.trimmingCharacters(in: .whitespaces).isEmpty {
                index += 1
                continue
            }

            if let fenced = fencedCode() {
                output.append(fenced)
                continue
            }

            if let heading = heading() {
                output.append(heading)
                continue
            }

            if isHorizontalRule(line) {
                output.append("<hr>")
                index += 1
                continue
            }

            if line.trimmingCharacters(in: .whitespaces).hasPrefix(">") {
                output.append(blockquote())
                continue
            }

            if isTable(at: index) {
                output.append(table())
                continue
            }

            if let item = listItem(line) {
                output.append(list(indent: item.indent, ordered: item.ordered))
                continue
            }

            output.append(paragraph())
        }

        return output.joined(separator: "\n")
    }

    private func fencedCode() -> String? {
        let trimmed = lines[index].trimmingCharacters(in: .whitespaces)
        let fence: String
        if trimmed.hasPrefix("```") {
            fence = "```"
        } else if trimmed.hasPrefix("~~~") {
            fence = "~~~"
        } else {
            return nil
        }

        let language = String(trimmed.dropFirst(3)).trimmingCharacters(in: .whitespaces)
        index += 1
        var code: [String] = []
        while index < lines.count {
            if lines[index].trimmingCharacters(in: .whitespaces).hasPrefix(fence) {
                index += 1
                break
            }
            code.append(lines[index])
            index += 1
        }

        let escaped = InlineMarkdown.escapeHTML(code.joined(separator: "\n"))
        if language.lowercased() == "mermaid" {
            return "<div class=\"mermaid-source\">\(escaped)</div>"
        }
        return "<pre><code>\(escaped)</code></pre>"
    }

    private func heading() -> String? {
        let line = lines[index]
        if let match = line.firstMatch(pattern: #"^\s*(#{1,6})\s+(.+?)\s*#*\s*$"#) {
            let level = match[1].count
            index += 1
            return "<h\(level)>\(InlineMarkdown.render(match[2]))</h\(level)>"
        }

        guard index + 1 < lines.count else { return nil }
        let underline = lines[index + 1].trimmingCharacters(in: .whitespaces)
        if underline.range(of: #"^=+\s*$"#, options: .regularExpression) != nil {
            index += 2
            return "<h1>\(InlineMarkdown.render(line))</h1>"
        }
        if underline.range(of: #"^-+\s*$"#, options: .regularExpression) != nil {
            index += 2
            return "<h2>\(InlineMarkdown.render(line))</h2>"
        }
        return nil
    }

    private func blockquote() -> String {
        var quoted: [String] = []
        while index < lines.count {
            let line = lines[index]
            guard let match = line.firstMatch(pattern: #"^\s*>\s?(.*)$"#) else { break }
            quoted.append(match[1])
            index += 1
        }
        let quotedMarkdown = quoted.joined(separator: "\n")
        let content: String
        if nestingDepth < Self.maximumNestingDepth {
            content = MarkdownParser(
                markdown: quotedMarkdown,
                nestingDepth: nestingDepth + 1
            ).parse()
        } else {
            content = "<p>\(InlineMarkdown.render(quotedMarkdown))</p>"
        }
        return "<blockquote>\(content)</blockquote>"
    }

    private func table() -> String {
        let headers = tableCells(lines[index])
        let delimiters = tableCells(lines[index + 1])
        index += 2

        let alignments = delimiters.map { cell -> String in
            let trimmed = cell.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix(":") && trimmed.hasSuffix(":") { return "center" }
            if trimmed.hasSuffix(":") { return "right" }
            return "left"
        }

        var rows: [[String]] = []
        while index < lines.count {
            let line = lines[index]
            guard line.contains("|"),
                  !line.trimmingCharacters(in: .whitespaces).isEmpty else { break }
            rows.append(tableCells(line))
            index += 1
        }

        var html = "<div class=\"table-scroll\"><table><thead><tr>"
        for (column, header) in headers.enumerated() {
            let alignment = alignments.indices.contains(column) ? alignments[column] : "left"
            html += "<th style=\"text-align:\(alignment)\">\(InlineMarkdown.render(header))</th>"
        }
        html += "</tr></thead><tbody>"
        for row in rows {
            html += "<tr>"
            for column in headers.indices {
                let cell = row.indices.contains(column) ? row[column] : ""
                let alignment = alignments.indices.contains(column) ? alignments[column] : "left"
                html += "<td style=\"text-align:\(alignment)\">\(InlineMarkdown.render(cell))</td>"
            }
            html += "</tr>"
        }
        html += "</tbody></table></div>"
        return html
    }

    private func list(indent: Int, ordered: Bool, depth: Int = 0) -> String {
        let tag = ordered ? "ol" : "ul"
        var startAttribute = ""
        if ordered, let first = listItem(lines[index]),
           let start = Int(first.marker.filter(\.isNumber)), start != 1 {
            startAttribute = " start=\"\(start)\""
        }
        var html = "<\(tag)\(startAttribute)>"

        while index < lines.count {
            guard let item = listItem(lines[index]) else { break }
            if item.indent < indent { break }
            if item.indent > indent {
                guard depth < Self.maximumNestingDepth else {
                    index += 1
                    html += "<li>\(InlineMarkdown.render(item.content))</li>"
                    continue
                }
                html += list(
                    indent: item.indent,
                    ordered: item.ordered,
                    depth: depth + 1
                )
                continue
            }
            if item.ordered != ordered { break }

            index += 1
            var content = item.content
            var taskClass = ""
            var checkbox = ""
            if let task = content.firstMatch(pattern: #"^\[([ xX])\]\s+(.*)$"#) {
                let checked = task[1].lowercased() == "x"
                taskClass = checked ? " class=\"task done\"" : " class=\"task\""
                checkbox = "<input type=\"checkbox\" disabled\(checked ? " checked" : "")>"
                content = task[2]
            }

            html += "<li\(taskClass)>\(checkbox)\(InlineMarkdown.render(content))"

            while index < lines.count, let nested = listItem(lines[index]), nested.indent > indent {
                guard depth < Self.maximumNestingDepth else {
                    index += 1
                    html += "<br>\(InlineMarkdown.render(nested.content))"
                    continue
                }
                html += list(
                    indent: nested.indent,
                    ordered: nested.ordered,
                    depth: depth + 1
                )
            }

            var continuation: [String] = []
            while index < lines.count {
                let next = lines[index]
                if next.trimmingCharacters(in: .whitespaces).isEmpty { break }
                if listItem(next) != nil || isBlockStart(at: index) { break }
                continuation.append(next.trimmingCharacters(in: .whitespaces))
                index += 1
            }
            if !continuation.isEmpty {
                html += " " + InlineMarkdown.render(continuation.joined(separator: " "))
            }
            html += "</li>"
        }

        html += "</\(tag)>"
        return html
    }

    private func paragraph() -> String {
        var paragraphLines: [String] = []
        while index < lines.count {
            let line = lines[index]
            if line.trimmingCharacters(in: .whitespaces).isEmpty { break }
            if !paragraphLines.isEmpty && isBlockStart(at: index) { break }
            paragraphLines.append(line.trimmingCharacters(in: .whitespaces))
            index += 1
        }
        return "<p>\(InlineMarkdown.render(paragraphLines.joined(separator: " ")))</p>"
    }

    private func isBlockStart(at position: Int) -> Bool {
        guard lines.indices.contains(position) else { return false }
        let line = lines[position]
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        return trimmed.hasPrefix("```")
            || trimmed.hasPrefix("~~~")
            || trimmed.hasPrefix(">")
            || line.range(of: #"^\s*#{1,6}\s+"#, options: .regularExpression) != nil
            || isHorizontalRule(line)
            || listItem(line) != nil
            || isTable(at: position)
    }

    private func isHorizontalRule(_ line: String) -> Bool {
        line.range(
            of: #"^\s{0,3}((\*\s*){3,}|(-\s*){3,}|(_\s*){3,})$"#,
            options: .regularExpression
        ) != nil
    }

    private func isTable(at position: Int) -> Bool {
        guard position + 1 < lines.count, lines[position].contains("|") else { return false }
        let delimiters = tableCells(lines[position + 1])
        return !delimiters.isEmpty && delimiters.allSatisfy {
            $0.trimmingCharacters(in: .whitespaces)
                .range(of: #"^:?-{3,}:?$"#, options: .regularExpression) != nil
        }
    }

    private func tableCells(_ line: String) -> [String] {
        var value = line.trimmingCharacters(in: .whitespaces)
        if value.hasPrefix("|") { value.removeFirst() }
        if value.hasSuffix("|") { value.removeLast() }
        return value.split(separator: "|", omittingEmptySubsequences: false).map {
            String($0).trimmingCharacters(in: .whitespaces)
        }
    }

    private struct ListItem {
        let indent: Int
        let marker: String
        let ordered: Bool
        let content: String
    }

    private func listItem(_ line: String) -> ListItem? {
        guard let match = line.firstMatch(pattern: #"^([ \t]*)([-+*]|\d+[.)])\s+(.+)$"#) else {
            return nil
        }
        let indentation = match[1].reduce(0) { $1 == "\t" ? $0 + 4 : $0 + 1 }
        let marker = match[2]
        return ListItem(
            indent: indentation,
            marker: marker,
            ordered: marker.first?.isNumber == true,
            content: match[3]
        )
    }
}

nonisolated private enum InlineMarkdown {
    private static let tokenPrefix = "\u{E000}"
    private static let tokenSuffix = "\u{E001}"

    static func render(_ source: String) -> String {
        var tokens: [String] = []
        var text = protectEscapes(in: source, tokens: &tokens)

        text = text.replacingMatches(pattern: #"`([^`\n]+)`"#) { groups in
            token("<code>\(escapeHTML(groups[1]))</code>", tokens: &tokens)
        }

        text = text.replacingMatches(pattern: #"!\[([^\]]*)\]\(([^\s\)]+)(?:\s+["'][^"']*["'])?\)"#) { groups in
            token("<span class=\"image-alt\">\(escapeHTML(groups[1]))</span>", tokens: &tokens)
        }

        text = text.replacingMatches(pattern: #"\[([^\]]+)\]\(([^\s\)]+)(?:\s+["'][^"']*["'])?\)"#) { groups in
            let label = escapeHTML(groups[1])
            guard let url = safeURL(groups[2]) else {
                return token(label, tokens: &tokens)
            }
            return token(
                "<a href=\"\(escapeHTML(url))\" rel=\"noreferrer noopener\">\(label)</a>",
                tokens: &tokens
            )
        }

        text = escapeHTML(text)
        text = text.replacingMatches(pattern: #"\*\*(.+?)\*\*"#) { "<strong>\($0[1])</strong>" }
        text = text.replacingMatches(pattern: #"__(.+?)__"#) { "<strong>\($0[1])</strong>" }
        text = text.replacingMatches(pattern: #"~~(.+?)~~"#) { "<del>\($0[1])</del>" }
        text = text.replacingMatches(pattern: #"(?<!\*)\*([^*\n]+)\*(?!\*)"#) { "<em>\($0[1])</em>" }
        text = text.replacingMatches(pattern: #"(?<!\w)_([^_\n]+)_(?!\w)"#) { "<em>\($0[1])</em>" }

        text = text.replacingMatches(
            pattern: "\(tokenPrefix)(\\d+)\(tokenSuffix)"
        ) { groups in
            guard let index = Int(groups[1]), tokens.indices.contains(index) else {
                return groups[0]
            }
            return tokens[index]
        }
        return text
    }

    static func escapeHTML(_ string: String) -> String {
        string
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&#39;")
    }

    private static func protectEscapes(in source: String, tokens: inout [String]) -> String {
        let escapable = #"\\`*{}[]()#+-.!_|>~"#
        var result = ""
        var index = source.startIndex

        while index < source.endIndex {
            let character = source[index]
            let next = source.index(after: index)
            if character == "\\", next < source.endIndex, escapable.contains(source[next]) {
                result += token(escapeHTML(String(source[next])), tokens: &tokens)
                index = source.index(after: next)
            } else {
                result.append(character)
                index = next
            }
        }
        return result
    }

    private static func safeURL(_ string: String) -> String? {
        let decoded = string.removingPercentEncoding ?? string
        guard let components = URLComponents(string: decoded),
              let scheme = components.scheme?.lowercased(),
              ["http", "https", "mailto"].contains(scheme) else {
            return nil
        }
        return string
    }

    private static func token(_ html: String, tokens: inout [String]) -> String {
        tokens.append(html)
        return tokenKey(tokens.count - 1)
    }

    private static func tokenKey(_ index: Int) -> String {
        "\(tokenPrefix)\(index)\(tokenSuffix)"
    }
}

nonisolated private extension String {
    func firstMatch(pattern: String) -> [String]? {
        guard let expression = RegularExpressionCache.expression(for: pattern),
              let match = expression.firstMatch(
                in: self,
                range: NSRange(startIndex..., in: self)
              ) else {
            return nil
        }

        return (0..<match.numberOfRanges).map { index in
            let range = match.range(at: index)
            guard range.location != NSNotFound,
                  let swiftRange = Range(range, in: self) else { return "" }
            return String(self[swiftRange])
        }
    }

    func replacingMatches(
        pattern: String,
        transform: ([String]) -> String
    ) -> String {
        guard let expression = RegularExpressionCache.expression(for: pattern) else { return self }
        let mutable = NSMutableString(string: self)
        let matches = expression.matches(in: self, range: NSRange(startIndex..., in: self))

        for match in matches.reversed() {
            let groups = (0..<match.numberOfRanges).map { index -> String in
                let range = match.range(at: index)
                guard range.location != NSNotFound else { return "" }
                return mutable.substring(with: range)
            }
            mutable.replaceCharacters(in: match.range, with: transform(groups))
        }
        return mutable as String
    }
}

nonisolated private enum RegularExpressionCache {
    private static let cache = NSCache<NSString, NSRegularExpression>()

    static func expression(for pattern: String) -> NSRegularExpression? {
        let key = pattern as NSString
        if let expression = cache.object(forKey: key) {
            return expression
        }
        guard let expression = try? NSRegularExpression(pattern: pattern) else {
            return nil
        }
        cache.setObject(expression, forKey: key)
        return expression
    }
}
