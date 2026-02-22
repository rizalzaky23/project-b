<?php

namespace App\Services;

use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class PhotoUploadService
{
    /**
     * Upload a single photo and return the stored path.
     */
    public function upload(UploadedFile $file, string $folder): string
    {
        $filename = Str::uuid() . '.' . $file->getClientOriginalExtension();
        $path = $file->storeAs("public/{$folder}", $filename);
        // Return the public URL path (without "public/")
        return Storage::url($path);
    }

    /**
     * Upload multiple photos by field names from request.
     * Returns an associative array of fieldName => stored path.
     */
    public function uploadMany(array $files, string $folder): array
    {
        $paths = [];
        foreach ($files as $field => $file) {
            if ($file instanceof UploadedFile) {
                $paths[$field] = $this->upload($file, $folder);
            }
        }
        return $paths;
    }

    /**
     * Delete a file by its stored URL path.
     */
    public function delete(?string $url): void
    {
        if (!$url) return;

        // Convert URL like /storage/folder/file.jpg -> public/folder/file.jpg
        $path = 'public/' . ltrim(str_replace('/storage/', '', $url), '/');
        if (Storage::exists($path)) {
            Storage::delete($path);
        }
    }

    /**
     * Delete multiple files.
     */
    public function deleteMany(array $urls): void
    {
        foreach ($urls as $url) {
            $this->delete($url);
        }
    }
}
