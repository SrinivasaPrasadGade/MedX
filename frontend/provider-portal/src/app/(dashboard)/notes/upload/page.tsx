"use client";

import { useState } from "react";
import { Button } from "@/components/ui/Button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/Card";
import { UploadCloud, FileText, CheckCircle, AlertCircle, RefreshCw } from "lucide-react";
import { cn } from "@/lib/utils";

export default function NotesUploadPage() {
  const [isDragging, setIsDragging] = useState(false);
  const [file, setFile] = useState<File | null>(null);
  const [status, setStatus] = useState<"idle" | "uploading" | "processing" | "complete">("idle");
  const [progress, setProgress] = useState(0);

  const handleDragOver = (e: React.DragEvent) => {
    e.preventDefault();
    setIsDragging(true);
  };

  const handleDragLeave = () => {
    setIsDragging(false);
  };

  const handleDrop = (e: React.DragEvent) => {
    e.preventDefault();
    setIsDragging(false);
    if (e.dataTransfer.files && e.dataTransfer.files[0]) {
      setFile(e.dataTransfer.files[0]);
    }
  };

  const simulateProcessing = () => {
    if (!file) return;
    setStatus("uploading");
    
    // Simulate steps
    let p = 0;
    const interval = setInterval(() => {
      p += 5;
      setProgress(p);
      
      if (p >= 20 && p < 40) setStatus("processing"); // OCR
      if (p >= 40 && p < 80) setStatus("processing"); // NLP
      if (p >= 100) {
        clearInterval(interval);
        setStatus("complete");
      }
    }, 200);
  };

  return (
    <div className="max-w-5xl mx-auto space-y-8">
      <div>
        <h1 className="text-3xl font-semibold tracking-tight">Clinical Notes Processor</h1>
        <p className="text-muted-foreground mt-2">
          Upload handwritten notes or PDFs to extract structured FHIR data.
        </p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* Upload Area */}
        <div className="lg:col-span-2 space-y-6">
          <Card 
            className={cn(
              "border-2 border-dashed transition-colors h-64 flex flex-col items-center justify-center cursor-pointer",
              isDragging ? "border-primary bg-primary/5" : "border-border hover:bg-secondary/50",
              status !== "idle" && "opacity-50 pointer-events-none"
            )}
            onDragOver={handleDragOver}
            onDragLeave={handleDragLeave}
            onDrop={handleDrop}
            onClick={() => {
                // In a real app, trigger hidden file input
            }}
          >
            <div className="text-center space-y-4">
              <div className="w-16 h-16 bg-secondary rounded-full flex items-center justify-center mx-auto">
                <UploadCloud className="w-8 h-8 text-primary" />
              </div>
              <div>
                <p className="font-medium">Click to upload or drag and drop</p>
                <p className="text-sm text-muted-foreground">PDF, JPEG, or PNG (max. 10MB)</p>
              </div>
              {file && (
                <div className="flex items-center gap-2 text-sm font-medium bg-primary/10 text-primary px-3 py-1 rounded-full mx-auto w-fit">
                  <FileText className="w-4 h-4" />
                  {file.name}
                </div>
              )}
            </div>
          </Card>

          {file && status === "idle" && (
            <Button onClick={simulateProcessing} className="w-full">
              Process Document
            </Button>
          )}

          {/* Progress Section */}
          {status !== "idle" && (
            <Card className="glass-card">
              <CardContent className="pt-6 space-y-4">
                <div className="flex justify-between text-sm font-medium">
                  <span>
                    {status === "uploading" && "Uploading Document..."}
                    {status === "processing" && "Extracting Medical Entities (AI)..."}
                    {status === "complete" && "Processing Complete"}
                  </span>
                  <span>{progress}%</span>
                </div>
                <div className="h-2 bg-secondary rounded-full overflow-hidden">
                  <div 
                    className="h-full bg-primary transition-all duration-300 ease-out"
                    style={{ width: `${progress}%` }}
                  />
                </div>
                
                <div className="grid grid-cols-3 gap-4 pt-4">
                  <StatusStep label="OCR" active={progress > 20} done={progress > 40} />
                  <StatusStep label="NLP Extraction" active={progress > 40} done={progress > 80} />
                  <StatusStep label="FHIR Gen" active={progress > 80} done={progress === 100} />
                </div>
              </CardContent>
            </Card>
          )}
        </div>

        {/* Info / Results Sidebar */}
        <div className="space-y-6">
            <Card>
                <CardHeader>
                    <CardTitle>Supported Formats</CardTitle>
                </CardHeader>
                <CardContent className="text-sm text-muted-foreground space-y-2">
                    <p>• Scanned PDF Documents</p>
                    <p>• Clinical Images (JPEG/PNG)</p>
                    <p>• HL7 v2 Messages</p>
                    <p>• Plain Text Notes</p>
                </CardContent>
            </Card>

            {status === "complete" && (
                <Card className="bg-success-green/10 border-success-green/20">
                    <CardHeader>
                        <CardTitle className="text-success-green flex items-center gap-2">
                            <CheckCircle className="w-5 h-5" />
                            Extraction Success
                        </CardTitle>
                    </CardHeader>
                    <CardContent className="space-y-4">
                        <div className="text-sm">
                            <p className="font-medium text-foreground">Entities Found:</p>
                            <ul className="list-disc pl-4 mt-1 space-y-1 text-muted-foreground">
                                <li>2 Medications</li>
                                <li>1 Diagnosis (Hypertension)</li>
                                <li>1 Vital Sign (BP)</li>
                            </ul>
                        </div>
                        <Button className="w-full" variant="outline">View Extracted Data</Button>
                    </CardContent>
                </Card>
            )}
        </div>
      </div>
    </div>
  );
}

function StatusStep({ label, active, done }: { label: string, active: boolean, done: boolean }) {
    return (
        <div className={cn("text-center space-y-2", (!active && !done) && "opacity-40")}>
            <div className={cn(
                "w-8 h-8 rounded-full flex items-center justify-center mx-auto border-2",
                done ? "bg-primary border-primary text-primary-foreground" :
                active ? "border-primary text-primary" : "border-muted text-muted"
            )}>
                {done ? <CheckCircle className="w-5 h-5" /> : 
                 active ? <RefreshCw className="w-4 h-4 animate-spin" /> : 
                 <div className="w-2 h-2 rounded-full bg-muted" />}
            </div>
            <p className="text-xs font-medium">{label}</p>
        </div>
    )
}
